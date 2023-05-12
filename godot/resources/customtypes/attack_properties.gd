extends Resource
class_name AttackProperties



@export var damage: int = 10
@export var launch_power: float = 10.0
@export var stun_time: float = 0.2
@export var position_offset: Vector2 = Vector2.ZERO
@export var knockup_amount: float = 1.0

func _init(dmg: int = 10, power: float = 10.0, stun: float = 0.2, offset: Vector2 = Vector2.ZERO):
	damage = dmg
	launch_power = power
	stun_time = stun

func serialize() -> Dictionary:
	var serialized = {
		dmg = damage,
		power = launch_power,
		stun = stun_time
	}
	
	return serialized