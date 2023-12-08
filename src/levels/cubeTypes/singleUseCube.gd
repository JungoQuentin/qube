extends Cube
class_name SingleUseCube

var is_used: bool = false
var _true_material: Material
var _wird_tween: Tween


func on_leave():
	super.on_leave()
	is_used = true
	_change_color_animation_start()


func on_touch():
	if is_used:
		return
	mesh = mesh.duplicate(true)
	mesh_instance.mesh = mesh
	_true_material = mesh_instance.mesh.surface_get_material(0)
	initial_color = Colors.blocking_init_color
	touched_color = Colors.darker(initial_color)
	_wird_animation_start()


func _change_color_animation_start():
	touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	touch_tween.tween_property(_true_material, "albedo_color", initial_color, 1)
	touch_tween.tween_callback(func(): touch_tween = null)


func _wird_animation_start():
	if is_used and _wird_tween != null:
		_wird_tween.kill()
		_wird_tween = null
		return
	_wird_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	_wird_tween.tween_property(_true_material, "albedo_color", touched_color, 1)
	_wird_tween.tween_property(_true_material, "albedo_color", initial_color, 1)
	_wird_tween.tween_callback(_wird_animation_start)


func update_color():
	if _wird_tween: _wird_tween.kill(); _wird_tween = null
	if touch_tween: touch_tween.kill(); touch_tween = null
	if is_used:
		initial_color = Colors.blocking_init_color
		touched_color = Colors.darker(initial_color)
	else:
		initial_color = Colors.single_cube_init_color
		touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color
	if _true_material: _true_material.albedo_color = initial_color
	mesh.surface_get_material(0).albedo_color = initial_color

func reset():
	# TODO
	print("reset single use cube TODO")
