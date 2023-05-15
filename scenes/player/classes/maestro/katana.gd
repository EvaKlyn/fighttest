extends MeleeWeapon

func attack(attack_state) -> void:
	if attack_state == "walk" or attack_state == "idle":
		if not attacking:
			weapon_anims.play("swing")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.queue("swing")
		
	if attack_state == "sprint":
		if not attacking:
			weapon_anims.play("swing_2")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.queue("swing_2")
	
	if attack_state == "crouch":
		if not attacking:
			weapon_anims.play("air_swing")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("air_swing")
	
	if attack_state == "dodge":
		if not attacking:
			weapon_anims.play("air_swing")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("air_swing")
	
	if attack_state == "air":
		if not attacking:
			weapon_anims.play("swing")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("swing")
			
	super(attack_state)
	weapon_anims.queue("idle")

func special(attack_state, index: int) -> void:
	if not (attacking and current_attack_type == "special"):
		if index == 1:
			var character: FighterMaestro = get_parent_node_3d()
			character.head.body_lock()
			weapon_anims.clear_queue()
			weapon_anims.play("special_1")
			character.special_timer_1 = character.special_cooldown_1
		
		if index == 2:
			var character: FighterMaestro = get_parent_node_3d()
			character.head.body_lock()
			weapon_anims.clear_queue()
			weapon_anims.play("special_2")
			character.special_timer_2 = character.special_cooldown_2
		
		if index == 3:
			var character: FighterMaestro = get_parent_node_3d()
			character.head.body_lock()
			weapon_anims.clear_queue()
			weapon_anims.play("special_3")
			character.special_timer_3 = character.special_cooldown_3
		
		current_attack_type = "special"
	
	super(attack_state, index)
	weapon_anims.queue("idle")

func shield_break(attack_state) -> void:
	super(attack_state)
	if not weapon_anims.is_playing():
			weapon_anims.play("shield_break")
	
	weapon_anims.queue("idle")
