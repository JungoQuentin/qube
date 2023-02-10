extends Node3D

@onready var camera = $Camera3D

@export var camera_y_distance = 10.:
	set(n):
		if camera: camera.position.y = n
		camera_y_distance = n

const camera_fov = 30.
const camera_y_dist_by_cube_dimension: Dictionary = {
	3: 7.8,
	5: 12.,
	7: 17.
}

func _ready():
	camera.fov = camera_fov
	var passed = 0.0
	while Global.map_cube == null and passed < 3:
		passed += 0.01
		await get_tree().create_timer(0.01).timeout
	camera.position.y = camera_y_dist_by_cube_dimension[Global.map_cube.dimension]
