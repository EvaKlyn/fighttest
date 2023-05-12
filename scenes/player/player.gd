extends FPSController3D
class_name Player

## Example script that extends [CharacterController3D] through 
## [FPSController3D].
## 
## This is just an example, and should be used as a basis for creating your 
## own version using the controller's [b]move()[/b] function.
## 
## This player contains the inputs that will be used in the function 
## [b]move()[/b] in [b]_physics_process()[/b].
## The input process only happens when mouse is in capture mode.
## This script also adds submerged and emerged signals to change the 
## [Environment] when we are in the water.

# Gameplay Values - Networked
@export var player_alias := "WHOOPS"
@export var current_animation_time: float = 0.0
@export var current_hp: int = 100

# gameplay values local
var guarding: bool = false
var guard_ended: bool = false
var shield_hp: float = 100
var taken_attack_ids: Array = []

#config stuff
@export_group("Class Config")
@export var current_weapon: MeleeWeapon
@export var body_animations: AnimationPlayer
@export var max_hp: int = 100
@export var max_shield_hp: int = 100
@export var knockback_multiplier: float = 1.0

@export_group("Input Conifg")
@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"

@export var underwater_env: Environment

@onready var synchronizer = $MultiplayerSynchronizer
@onready var hurt_sound = $HurtSound
@onready var shield_mesh = $ShieldMesh

var set_up = false
var last_input_state = {
	ax = Vector2.ZERO,
	jmp = false,
	crc = false,
	spr = false,
}

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if is_multiplayer_authority():
		shield_hp = max_shield_hp
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		setup()
		player_alias = MpGlobals.my_alias
		dodge_ability.actived.connect(func(): do_animation("dodge"))

func _physics_process(delta):
	if not set_up:
		camera.current = synchronizer.is_multiplayer_authority()
		if camera.current:
			$Vis.visible = false
		else:
			$CanvasLayer.visible = false
	
	if is_multiplayer_authority():
		var is_valid_input := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		var guarded_last_frame = guarding
		if guard_ended:
			guard_ended = false
		
		$Vis/Label3D.text = MpGlobals.my_alias
		$CanvasLayer/Hud/HpLabel.text = str((float(current_hp) / float(max_hp)) * 100) + "%"
		$CanvasLayer/Hud/TrueHpLabel.text = str(current_hp) + "/" + str(max_hp)
		if body_animations.is_playing():
			current_animation_time = body_animations.current_animation_position
			
		var input_axis = Input.get_vector(input_back_action_name, input_forward_action_name, input_left_action_name, input_right_action_name)
		var input_jump = Input.is_action_just_pressed(input_jump_action_name)
		var input_crouch = Input.is_action_pressed(input_crouch_action_name)
		var input_sprint = Input.is_action_pressed(input_sprint_action_name)
		var input_swim_down = Input.is_action_pressed(input_crouch_action_name)
		var input_swim_up = Input.is_action_pressed(input_jump_action_name)
		
		if not dodge and not hit_stunned and not guarding:
			if Input.is_action_just_pressed("attack"):
				current_weapon.attack(attack_state)
			if Input.is_action_just_pressed("special"):
				current_weapon.special(attack_state)
		
		if is_valid_input and not hit_stunned and not current_weapon.attacking:
			last_input_state = {
				ax = input_axis,
				jmp = input_jump,
				crc = input_crouch,
				spr = input_sprint,
			}
			
			if Input.is_action_pressed("guard") and shield_hp > 0:
				guarding = true
			else:
				guarding = false
			
			if guarded_last_frame and not guarding:
				guard_ended = true
				add_hit_stun(0.25)
			
			if guarding:
				move(delta, Vector2.ZERO, input_jump, input_crouch, input_sprint)
				shield_mesh.visible = true
				shield_hp -= 0.25
				var scale_fac = float(shield_hp / max_shield_hp)
				shield_mesh.scale = Vector3(scale_fac, scale_fac, scale_fac)
			else:
				move(delta, input_axis, input_jump, input_crouch, input_sprint)
				shield_mesh.visible = false
				if shield_hp < max_shield_hp:
					shield_hp += 0.5
				
		elif not hit_stunned:
			if is_on_floor():
				move(delta, input_axis, last_input_state.jmp, last_input_state.crc, last_input_state.spr, current_weapon.attack_move_multiplier)
			else:
				move(delta, last_input_state.ax, last_input_state.jmp, last_input_state.crc, last_input_state.spr)
		else:
			move(delta, Vector2.ZERO, last_input_state.jmp, last_input_state.crc, last_input_state.spr)
	else:
		$Vis/HealthLabel.text = str((float(current_hp) / float(max_hp)) * 100) + "%"
		body_animations.seek(current_animation_time)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		# Mouse look (only if the mouse is captured).
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if not current_weapon.attacking:
				rotate_head(event.relative)
			else:
				rotate_only_head(event.relative)
			$Vis/MeshInstance3D/Node3D.rotation = head.rotation

func reduce_health(damage: int):
	current_hp -= damage
	if current_hp <= 0:
		die()

func die():
	current_weapon.stop_attacks()
	MpGlobals.rpc_id(1, "respawn")
	current_hp = max_hp
	shield_hp = max_shield_hp

func do_animation(anim: String = "dodge"):
	body_animations.play(anim)

@rpc("any_peer", "call_local")
func teleport(pos: Vector3):
	print("tp to "+str(pos))
	hit_stun_time = 0.0
	velocity = Vector3.ZERO
	position = pos

@rpc("reliable", "any_peer")
func take_damage(attack_id: String, ser_props: Dictionary, knockback_angle: float, up_amt: float = 0.0):
	if not is_multiplayer_authority():
		return
	if attack_id in taken_attack_ids:
		return
	if hit_stunned:
		return
	if dodge:
		return
	
	if taken_attack_ids.size() > 5:
		taken_attack_ids.pop_front()
	taken_attack_ids.append(attack_id)
	
	var properties: AttackProperties
	if ser_props["dmg"] is int and ser_props["power"] is float and ser_props["stun"] is float:
		properties = AttackProperties.new(ser_props["dmg"], ser_props["power"], ser_props["stun"])
	else:
		properties = AttackProperties.new()
	
	var vec2_knockback = Vector2.from_angle(knockback_angle)
	var knockback_calculated = Vector3(vec2_knockback.x, 0, vec2_knockback.y)
	
	knockback.power = properties.launch_power * knockback_multiplier
	knockback.angle = knockback_calculated
	knockback.knockup = up_amt
	
	is_hit = true
	
	if shield_hp > 10 and guarding:
		shield_hp -= properties.damage
		knockback.power = properties.launch_power * 0.25 * knockback_multiplier
		knockback.knockup = up_amt * 0.25
		return
	
	reduce_health(properties.damage)
	
	current_weapon.stop_attacks()
	add_hit_stun(properties.stun_time)

@rpc("unreliable", "call_local")
func play_sound(sound: String):
	if sound == "hurt":
		hurt_sound.play()