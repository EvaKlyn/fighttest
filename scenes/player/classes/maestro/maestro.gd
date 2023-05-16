extends Player
class_name FighterMaestro

@onready var animator = $Vis/CharacterModel/AnimationPlayer
var current_animator_time: float = 0.0

func _ready():
	if is_multiplayer_authority():
		special1_label.text = "Multistab"
		special2_label.text = "Taste"
		special3_label.text = "Charge"
	
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
