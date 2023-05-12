extends Node3D
class_name PlayerAudios3D

## Script that plays sounds based on player actions.
## Using an [AudioInteract] array synchronized with physic_materials array to 
## identify different sound structures for each type of physical material.

@onready var step_stream: AudioStreamPlayer3D = get_node(NodePath("Step"))
@onready var land_stream: AudioStreamPlayer3D = get_node(NodePath("Land"))
@onready var jump_stream: AudioStreamPlayer3D = get_node(NodePath("Jump"))
@onready var crouch_stream: AudioStreamPlayer3D = get_node(NodePath("Crouch"))
@onready var uncrouch_stream: AudioStreamPlayer3D = get_node(NodePath("Uncrouch"))
@onready var raycast: RayCast3D = get_node(NodePath("Detect Ground"))
@onready var character_body: CharacterBody3D = get_node(NodePath(".."))
@onready var character_controller: CharacterController3D = get_node(NodePath(".."))

@export var muted = false

func _ready():
	set_multiplayer_authority(character_controller.name.to_int())
	
	character_controller.stepped.connect(_on_controller_stepped)
	character_controller.crouched.connect(_on_controller_crouched)
	character_controller.jumped.connect(_on_controller_jumped)
	character_controller.landed.connect(_on_controller_landed)
	character_controller.uncrouched.connect(_on_controller_uncrouched)
	character_controller.entered_the_water.connect(_on_controller_entered_the_water)
	character_controller.exit_the_water.connect(_on_controller_exit_the_water)

func _on_controller_jumped():
	if is_multiplayer_authority():
		rpc("do_sound")
	

func _on_controller_landed():
	if is_multiplayer_authority():
		rpc("do_sound")
	

func _on_controller_stepped():
	if is_multiplayer_authority():
		if not character_controller.is_crouching() and not muted:
			rpc("do_sound")

func _on_controller_crouched():
	if is_multiplayer_authority():
		rpc("do_sound")


func _on_controller_uncrouched():
	if is_multiplayer_authority():
		if not muted:
			rpc("do_sound")


func _on_controller_entered_the_water():
	if is_multiplayer_authority():
		land_stream.play()

func _on_controller_exit_the_water():
	if is_multiplayer_authority():
		jump_stream.play()

@rpc("unreliable", "call_local")
func do_sound():
	step_stream.play()
