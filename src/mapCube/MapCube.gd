extends Node3D
class_name MapCube

@export var dimension: int = 0

func _ready():
	if dimension == 0:
		Log.crash("dimension not set !!")
