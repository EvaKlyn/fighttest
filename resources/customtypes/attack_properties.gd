extends Resource
class_name AttackProperties

@export var damage: int = 10
@export var launch_power: float = 10.0
@export var stun_time: float = 0.2
@export var position_offset: Vector2 = Vector2.ZERO
@export var knockup_amount: float = 1.0
@export var shattering: bool = false
@export var healing: int = 0

func _init(dmg: int = 10, power: float = 10.0, stun: float = 0.2, offset: Vector2 = Vector2.ZERO, shatter: bool = false, heal: int = 0.0):
	damage = dmg
	launch_power = power
	stun_time = stun
	position_offset = offset
	shattering = shatter
	healing = heal

func serialize() -> Dictionary:
	var serialized = {
		dmg = damage,
		power = launch_power,
		stun = stun_time,
		shatter = shattering,
		heal = healing
	}
	
	return serialized
