extends Area3D
class_name Projectile3D

const uuid = preload("res://util/uuid.gd")

@export var attack_properties: AttackProperties
var creator: Player

var attack_id: String

func _ready():
	set_multiplayer_authority(get_parent().get_parent().get_multiplayer_authority())
	creator = get_parent().get_parent()
	attack_id = uuid.new().as_string()

func _physics_process(delta):
	if is_multiplayer_authority():
		behavior(delta)
		for body in get_overlapping_bodies():
			if body is Player and not body == creator:
				if not body == creator:
					var forward_vec = position.direction_to(body.position)
					var dmg_angle = Vector2(forward_vec.x, forward_vec.z).angle()
					dmg_angle = dmg_angle + attack_properties.position_offset.angle()
					body.rpc("take_damage", attack_id, attack_properties.serialize(), dmg_angle, attack_properties.knockup_amount)
				queue_free()


# override this with the projectile behavior
func behavior(delta: float):
	pass
