extends Node3D

@onready var camera = $Camera3D

@export var camera_y_distance = 10.:
	set(n):
		if camera: camera.position.y = n

@export var camera_fov = 30.:
	set(n):
		if camera: camera.fov = n

