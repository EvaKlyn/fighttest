extends MovementAbility3D
class_name DodgeAbility3D

signal dodged

@export var dodge_strength: float = 15.0
@export var dodge_cooldown: float = 0.8
@export var iframe_duration: float = 0.3

var just_dodged = false

func apply(velocity: Vector3, speed : float, is_on_floor : bool, direction : Vector3, delta: float) -> Vector3:
	if not is_actived():
		return velocity
	if not is_on_floor:
		return velocity
	if just_dodged:
		return velocity
	if velocity.length() < 5.0:
		return velocity
	
	var temp_velocity := velocity
	temp_velocity = direction * dodge_strength
	temp_velocity.y = 0
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	just_dodged = true
	
	get_parent().dodge = true
	get_tree().create_timer(dodge_cooldown).timeout.connect(func(): just_dodged = false)
	get_tree().create_timer(iframe_duration).timeout.connect(func(): get_parent().dodge = false)
	
	emit_signal("dodged")
	
	return velocity
	
func set_active(a : bool) -> void:
	if just_dodged:
		emit_signal("deactived")
	else:
		super(a)
