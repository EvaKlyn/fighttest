extends MovementAbility3D
class_name RisingAbility3D

signal dodged

@export var up_impulse: float = 16.0

var just_activated = false

func apply(velocity: Vector3, speed : float, is_on_floor : bool, direction : Vector3, delta: float) -> Vector3:
	if not is_actived():
		return velocity
	if just_activated:
		return velocity
	
	velocity.y = up_impulse
	
	set_active(false)
	return velocity
