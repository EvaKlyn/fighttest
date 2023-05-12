extends MovementAbility3D
class_name KnockBackAbility3D

var power := 10.0
var angle := Vector3.ZERO
var knockup := 1.0

func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	if is_actived():
		var parent = get_parent_node_3d()
		var launch_vector = angle.normalized() * power
		var up_vector = Vector3.UP * knockup
		parent.rpc("play_sound", "hurt")
		velocity += launch_vector * 2.5
		velocity += up_vector
	return velocity
