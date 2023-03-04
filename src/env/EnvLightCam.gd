extends Node3D

@onready var camera = $Camera3D
@onready var camera_db = $Camera3D_debug

@export var camera_y_distance = 10.:
	set(n):
		if camera: camera.position.y = n
		camera_y_distance = n

const camera_fov = 30.
const camera_y_dist_by_cube_dimension: Dictionary = {
	3: 9,
	5: 15.,
	7: 20.
}

@export var debug = false


func _ready():
	camera.fov = camera_fov
	await Utils.wait_while(func(): return Level.map_cube == null)
	camera.position.y = camera_y_dist_by_cube_dimension[Level.map_cube.dimension]
	$WorldEnvironment.environment.background_color = Colors.background_color
	camera.current = true
	camera_db.current = debug
	if Colors.inner_light_fade:
		$lights/inner.light_color = Colors.inner_light_color
		_start_inner_light_animation()

func _start_inner_light_animation():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($lights/inner, "light_energy", Colors.fade_from, Colors.fade_speed)
	tween.tween_property($lights/inner, "light_energy", Colors.fade_to,   Colors.fade_speed)
	tween.tween_callback(_start_inner_light_animation)
	tween.play()
