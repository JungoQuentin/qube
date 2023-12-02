extends Camera3D

@onready var level:= get_tree().current_scene
const camera_fov = 30.
const camera_y_dist_by_cube_dimension: Dictionary = {
	3: 9,
	5: 15.,
	7: 20.
}

func _ready():
	fov = camera_fov
	await Utils.wait_while(func(): return level.map_cube == null)
	position.y = camera_y_dist_by_cube_dimension[level.map_cube.dimension]
	current = true
