extends Node3D

func _ready():
	MpGlobals.spawn_points.append(self.global_position)
