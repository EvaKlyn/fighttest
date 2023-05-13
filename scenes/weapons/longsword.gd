extends MeleeWeapon

@export var alt_hitbox: MeleeHitbox

var alt_hitbox_active: bool = false

func _physics_process(delta):
	super(delta)
	if is_multiplayer_authority():
		if alt_hitbox_active:
				for body in alt_hitbox.get_overlapping_bodies():
					if body is Player:
						if not body.hit_stunned:
							var forward_vec = get_parent_node_3d().position.direction_to(body.position)
							var dmg_angle = Vector2(forward_vec.x, forward_vec.z).angle()
							dmg_angle = dmg_angle + current_attack_properties.position_offset.angle()
							body.rpc("take_damage", current_attack_id, current_attack_properties.serialize(), dmg_angle, current_attack_properties.knockup_amount)

func attack(attack_state) -> void:
	if attack_state == "walk" or attack_state == "idle":
		if not attacking:
			weapon_anims.play("swing")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.queue("swing")
		
	if attack_state == "sprint":
		if not attacking:
			weapon_anims.play("swing2")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.queue("swing2")
	
	if attack_state == "crouch":
		if not attacking:
			weapon_anims.play("crouch_stab")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("crouch_stab")
	
	if attack_state == "dodge":
		if not attacking:
			weapon_anims.play("crouch_stab")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("crouch_stab")
	
	if attack_state == "air":
		if not attacking:
			weapon_anims.play("swing3")
		if attacking and attack_almost_finished():
			weapon_anims.clear_queue()
			weapon_anims.play("swing3")
			
	super(attack_state)
	weapon_anims.queue("idle")

func special(attack_state, index: int) -> void:
	if not (attacking and current_attack_type == "special") or (attack_almost_finished() and current_attack_type != "special"):
		if index == 1:
			weapon_anims.clear_queue()
			weapon_anims.play("special")
			current_attack_type = "special"
		if index == 2:
			var character: FighterBurial = get_parent_node_3d()
			if character.is_on_floor():
				weapon_anims.clear_queue()
				weapon_anims.play("special_2")
				character.rising_ability.set_active(true)
	
	super(attack_state, index)
	weapon_anims.queue("idle")

func shield_break(attack_state) -> void:
	super(attack_state)
	if not weapon_anims.is_playing():
			weapon_anims.play("shield_break")
	
	weapon_anims.queue("idle")

func activate_alt_hitbox(properties: AttackProperties):
	if not is_multiplayer_authority():
		return
	current_attack_properties = properties
	current_attack_id = uuid.new().as_string()
	alt_hitbox_active = true
	alt_hitbox.attacking = true

func deactivate_alt_hitbox():
	if not is_multiplayer_authority():
		return
	alt_hitbox_active = false
	alt_hitbox.attacking = false

func _do_sound():
	play_sound()
