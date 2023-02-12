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
	await Global.wait_while(func(): return Global.map_cube == null)
	camera.position.y = camera_y_dist_by_cube_dimension[Global.map_cube.dimension]

func _start_inner_light_animation():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($light/caca, "light_energy", 0.5, 2)
	tween.tween_property($light/caca, "light_energy", 2.0, 2)
	tween.tween_callback(_start_inner_light_animation)
	tween.play()