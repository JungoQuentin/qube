extends Node3D

@onready var camera = $Camera3D

@export var camera_y_distance = 10.:
	set(n):
		if camera: camera.position.y = n
		camera_y_distance = n

var camera_fov = 30.
#	set(n):
#		if camera: camera.fov = n
#		camera_fov = n

func _ready():
	camera.fov = camera_fov
	camera.position.y = camera_y_distance