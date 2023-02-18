extends Cube

var is_used: bool = false
var true_material: Material

func _ready():
	super._ready()
	cube_type = SINGLE_USE 
	initial_color = Colors.single_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color

func on_leave():
	super.on_leave()
	is_used = true
	_change_color_animation_start()

var new_mesh

func on_touch(direction: Vector3, cube):
	if not is_used:
		mesh = mesh.duplicate(true)
		mesh_instance.mesh = mesh
		true_material = mesh_instance.mesh.surface_get_material(0)
		initial_color = Colors.blocking_init_color
		touched_color = Colors.darker(initial_color)
		_wird_animation_start()
	else:
		super.on_touch(direction, cube)
		await Utils.wait_while(func(): return Global.player.is_moving)
		_send_cube_back(direction, cube)

func _change_color_animation_start():
	touch_tween.kill()
	touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	touch_tween.tween_property(true_material, "albedo_color", initial_color, 1)
	touch_tween.tween_callback(func(): touch_tween = null)
	touch_tween.play()

func _wird_animation_start():
	if is_used:
		return
	touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	touch_tween.tween_property(true_material, "albedo_color", touched_color, 1)
	touch_tween.tween_property(true_material, "albedo_color", initial_color, 1)
	touch_tween.tween_callback(_wird_animation_start)
	touch_tween.play()
