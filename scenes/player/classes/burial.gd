extends Player
class_name FighterBurial

@onready var rising_ability: RisingAbility3D = $RisingAbility3D

func _physics_process(delta):
	if is_multiplayer_authority():
		if not dodge and not hit_stunned and not guarding:
			if Input.is_action_just_pressed("special_1"):
				current_weapon.special(attack_state, 1)
			if Input.is_action_just_pressed("special_2"):
				current_weapon.special(attack_state, 2)
	
	super(delta)
