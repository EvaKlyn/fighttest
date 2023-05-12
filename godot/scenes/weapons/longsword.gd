extends MeleeWeapon

func attack(attack_state) -> void:
	super(attack_state)
	if attack_state == "walk" or attack_state == "idle":
		if not weapon_anims.is_playing():
			weapon_anims.play("swing")
		if weapon_anims.is_playing() and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.queue("swing")
		
	if attack_state == "sprint":
		if not weapon_anims.is_playing():
			weapon_anims.play("swing2")
		if weapon_anims.is_playing() and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.queue("swing2")
	
	if attack_state == "crouch":
		if not weapon_anims.is_playing():
			weapon_anims.play("crouch_stab")
		if weapon_anims.is_playing() and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("crouch_stab")
	
	if attack_state == "dodge":
		if not weapon_anims.is_playing():
			weapon_anims.play("crouch_stab")
		if weapon_anims.is_playing() and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("crouch_stab")
	
	if attack_state == "air":
		if not weapon_anims.is_playing():
			weapon_anims.play("swing3")
		if weapon_anims.is_playing() and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("swing3")
	
	weapon_anims.queue("idle")

func special(attack_state) -> void:
	super(attack_state)
	if not weapon_anims.is_playing():
			weapon_anims.play("special")
	
	weapon_anims.queue("idle")

func _do_sound():
	play_sound()
