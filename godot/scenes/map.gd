extends Node3D

func _ready():
	if PlayerSettings.potato_mode:
		$GPUParticles3D.queue_free()
		$GPUParticles3D2.queue_free()
		$VoxelGI.queue_free()
		$WorldEnvironment.environment = preload("res://resources/environments/rain_low.tres")
