extends Node3D

func _ready():
	$GPUParticles3D.emitting = true
	if is_multiplayer_authority():
		await get_tree().create_timer(2.0).timeout
		queue_free()
