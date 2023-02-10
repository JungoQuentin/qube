extends Cube

@onready var blockingCubePreload = preload("res://src/MapCube/cubeTypes/blockingCube.tscn")
var is_used = false

var true_material

func _ready():
	super._ready()
	initial_color = Global.single_cube_init_color
	touched_color = Global.single_cube_touched_color
	mesh.surface_get_material(0).albedo_color = initial_color

func on_leave():
	super.on_leave()
	is_used = true
	_change_color_animation_start()

var new_mesh

func on_touch():
	if not is_used:
		mesh = mesh.duplicate(true)
		mesh_instance.mesh = mesh
		true_material = mesh_instance.mesh.surface_get_material(0)
		initial_color = Global.blocking_init_color
		touched_color = Global.blocking_touched_color
		_wird_animation_start()
	else:
		super.on_touch()
		await Global.wait_player_end_rolling()
		Global.player.roll(-Global.direction)

func _change_color_animation_start():
	tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(true_material, "albedo_color", initial_color, 1)
	tween.tween_callback(func(): tween = null)
	tween.play()

func _wird_animation_start():
	if is_used:
		return
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(true_material, "albedo_color", touched_color, 1)
	tween.tween_property(true_material, "albedo_color", initial_color, 1)
	tween.tween_callback(_wird_animation_start)
	tween.play()
