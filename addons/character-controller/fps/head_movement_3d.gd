extends Marker3D
class_name HeadMovement3D

## Node that moves the character's head
## To move just call the function [b]rotate_camera[/b]
var original_position: Vector3

## Mouse sensitivity of rotation move
@export var mouse_sensitivity := 2.0

## Vertical angle limit of rotation move
@export var vertical_angle_limit := 90.0

## Actual rotation of movement
var actual_rotation := Vector3()
var body_locked := true

## Define mouse sensitivity
func set_mouse_sensitivity(sensitivity):
	mouse_sensitivity = sensitivity

## Define vertical angle limit for rotation movement of head
func set_vertical_angle_limit(limit : float):
	vertical_angle_limit = deg_to_rad(limit)

func _process(delta):
	original_position = position

## Rotates the head of the character that contains the camera used by 
## [FPSController3D].
## Vector2 is sent with reference to the input of a mouse as an example
func rotate_camera(mouse_axis : Vector2) -> void:
	if not body_locked:
		body_lock()
	# Vertical mouse look.
	actual_rotation.x = clamp(actual_rotation.x - mouse_axis.y * (mouse_sensitivity/1000), -vertical_angle_limit, vertical_angle_limit)
	get_owner().rotate_y(-1 *mouse_axis.x * (mouse_sensitivity/1000))
	rotation.x = actual_rotation.x

func rotate_only_camera(mouse_axis : Vector2) -> void:
	actual_rotation.x = clamp(actual_rotation.x - mouse_axis.y * (mouse_sensitivity/1000), -vertical_angle_limit, vertical_angle_limit)
	rotate_y(-1 * mouse_axis.x * (mouse_sensitivity/1000))
	rotation.x = actual_rotation.x
	body_locked = false

func body_lock():
	get_owner().rotation.y = global_rotation. y
	global_rotation. y = get_owner().rotation.y
	body_locked = true

func roll_dip():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector3(position.x, position.y - 1.3, position.z), 0.27).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", original_position, 0.22).set_trans(Tween.TRANS_SINE)
