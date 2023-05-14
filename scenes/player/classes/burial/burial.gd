extends Player
class_name FighterBurial

@onready var rising_ability: RisingAbility3D = $RisingAbility3D
@onready var projectile_world: Node3D = $ProjectileWorld
@onready var animator: AnimationPlayer = $Vis/CharacterModel/AnimationPlayer

var projectile = preload("res://scenes/player/classes/burial/projectile_dagger.tscn")
@export var current_animator_time: float = 0.0

func _ready():
	projectile_world.position = Vector3.ZERO
	projectile_world.rotation = Vector3.ZERO
	
	if is_multiplayer_authority():
		special1_label.text = "spin"
		special2_label.text = "rise"
		special3_label.text = "dagger"
		landed.connect(_on_landed)
	super()

func _physics_process(delta):
	if is_multiplayer_authority():
		if not dodge and not hit_stunned and not guarding:
			if Input.is_action_just_pressed("special_1") and (special_timer_1 <= 0.0):
				current_weapon.special(attack_state, 1)
			if Input.is_action_just_pressed("special_2") and (special_timer_2 <= 0.0):
				current_weapon.special(attack_state, 2)
			if Input.is_action_just_pressed("special_3") and (special_timer_3 <= 0.0):
				current_weapon.special(attack_state, 3)
		
		if velocity.length() > 2.0:
			if is_sprinting():
				if animator.current_animation != "run":
					animator.play("run")
			else:
				if animator.current_animation != "walk":
					animator.play("walk")
		
		else:
			animator.play("Idle")
		
		if not is_on_floor():
			if animator.current_animation != "jump":
				animator.play("jump")
		
		current_animator_time = animator.current_animation_position
		
	else:
		animator.seek(current_animator_time)
	
	super(delta)

func shoot_projectile():
	var new_dagger: Projectile3D = projectile.instantiate()
	projectile_world.add_child(new_dagger, true)
	new_dagger.transform = transform
	new_dagger.transform.origin.y += 0.5

func _on_landed():
	if velocity.length() > 3.0:
		if is_sprinting():
			if animator.current_animation != "run":
				animator.play("run")
		else:
			if animator.current_animation != "walk":
				animator.play("walk")
		
	else:
		animator.play("Idle")
