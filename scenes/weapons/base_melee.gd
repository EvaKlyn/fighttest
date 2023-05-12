extends Node3D
class_name MeleeWeapon

const uuid = preload("res://util/uuid.gd")

@export var weapon_model: Node3D
@export var weapon_anims: AnimationPlayer
@export var hitbox: MeleeHitbox
@export var sound: AudioStreamPlayer3D
@export var attack_move_multiplier: float = 0.0

@export_group("Network Variables")
@export var current_weapon_anim: String = ""
@export var current_animation_time: float = 0.0
@export var attack_active: bool = false

@onready var synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var clash_sound: AudioStreamPlayer3D = $ClashSound

var hitbox_active: bool = false
var current_attack_properties: AttackProperties = AttackProperties.new(10, 10.0, 0.2)
var attacking: bool = false
var current_attack_id = uuid.new().as_string()

func _ready():
	hitbox.body_entered.connect(func(body): _on_melee_hitbox_body_entered(body))
	hitbox.area_entered.connect(func(area): _on_melee_hitbox_area_entered(area))

func _physics_process(_delta):
	if is_multiplayer_authority():
		if weapon_anims.current_animation != "":
			current_weapon_anim = weapon_anims.current_animation
			current_animation_time = weapon_anims.current_animation_position
		
		if weapon_anims.current_animation == "idle" or weapon_anims.current_animation == "":
			attacking = false
		else:
			attacking = true
		
		if hitbox_active:
			for body in hitbox.get_overlapping_bodies():
				if body is Player:
					if not body.hit_stunned:
						var forward_vec = get_parent_node_3d().position.direction_to(body.position)
						var dmg_angle = Vector2(forward_vec.x, forward_vec.z).angle()
						dmg_angle = dmg_angle + current_attack_properties.position_offset.angle()
						body.rpc("take_damage", current_attack_id, current_attack_properties.serialize(), dmg_angle, current_attack_properties.knockup_amount)
		
		attack_active = hitbox.attacking
		
	if not is_multiplayer_authority():
		if current_weapon_anim != weapon_anims.current_animation:
			weapon_anims.play(current_weapon_anim)
		weapon_anims.seek(current_animation_time)
		hitbox.attacking = attack_active

func attack(attack_state) -> void:
	pass

func special(attack_state, index: int) -> void:
	pass
	
func shield_break(attack_state) -> void:
	pass
	
func attack_almost_finished() -> bool:
	var pos = weapon_anims.current_animation_position
	var end = weapon_anims.current_animation_length
	var thresh = 0.2
	
	if pos > (end - thresh):
		return true
	
	return false

func activate_melee_hitbox(properties: AttackProperties):
	if not is_multiplayer_authority():
		return
	current_attack_properties = properties
	current_attack_id = uuid.new().as_string()
	hitbox_active = true
	hitbox.attacking = true

func deactivate_melee_hitbox():
	if not is_multiplayer_authority():
		return
	hitbox_active = false
	hitbox.attacking = false

func stop_attacks():
	deactivate_melee_hitbox()
	weapon_anims.stop()
	weapon_anims.queue("idle")

func clash():
	stop_attacks()
	rpc("_network_clash_sound")
	weapon_anims.play("clash")
	weapon_anims.queue("idle")

func _on_melee_hitbox_body_entered(body):
	if attacking and weapon_anims.current_animation != "clash":
		if body is StaticBody3D:
			clash()
			
func _on_melee_hitbox_area_entered(area):
	if attacking and weapon_anims.current_animation != "clash":
		if area is MeleeHitbox:
			if area.attacking:
				clash()

func play_sound():
	if is_multiplayer_authority():
		rpc("_network_sound")

@rpc("reliable", "call_local")
func _network_sound():
	sound.play()

@rpc("reliable", "call_local")
func _network_clash_sound():
	clash_sound.play()
