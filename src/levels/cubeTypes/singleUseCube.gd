extends Cube
class_name SingleUseCube

var is_used:= false
var _color_changed:= false

func on_leave():
	super.on_leave()
	is_used = true
	_change_color_animation_start()


func on_touch():
	if is_used and not _color_changed:
		return
	super.on_touch()


func _change_color_animation_start():
	if _touch_tween_running():
		touch_tween.kill()
	initial_color = Colors.blocking_init_color
	touched_color = Colors.darker(initial_color)
	var _material = mesh_instance.get_surface_override_material(0)
	touch_tween = create_tween()
	touch_tween.tween_property(_material, "albedo_color", initial_color, 1)
	touch_tween.tween_callback(func(): touch_tween.kill(); _color_changed = true)

## Set the color according to the current state of the singleUseCube
func update_color():
	if _touch_tween_running(): 
		touch_tween.kill()
	if is_used:
		initial_color = Colors.blocking_init_color
		touched_color = Colors.darker(initial_color)
	else:
		initial_color = Colors.single_cube_init_color
		touched_color = Colors.darker(initial_color)
	mesh_instance.get_surface_override_material(0).albedo_color = initial_color


func reset():
	is_used = false
	_color_changed = false
	update_color()
