extends Player
class_name FighterMaestro

func _ready():
	if is_multiplayer_authority():
		special1_label.text = "Multistab"
		special2_label.text = ""
		special3_label.text = ""
	
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
	
	super(delta)
