extends Node3D

@onready var camera = $Camera3D

@export var camera_y_distance = 10.:
	set(n):
		if camera: camera.position.y = n
		camera_y_distance = n

const camera_fov = 30.
const camera_y_dist_by_cube_dimension: Dictionary = {
	3: 8,
	5: 10,
	7: 12
}

func _ready():
	camera.fov = camera_fov

	camera.position.y = camera_y_dist_by_cube_dimension[Global.map_cube.dimension]
