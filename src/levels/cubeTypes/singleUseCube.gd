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
		_touch_tween.kill()
	_initial_color = Colors.blocking_init_color
	_touched_color = Colors.darker(_initial_color)
	var _material = _mesh_instance.get_surface_override_material(0)
	_touch_tween = create_tween()
	_touch_tween.tween_property(_material, "albedo_color", _initial_color, 1)
	_touch_tween.tween_callback(func(): _touch_tween.kill(); _color_changed = true)

## Set the color according to the current state of the singleUseCube
func update_color():
	if _touch_tween_running(): 
		_touch_tween.kill()
	if is_used:
		_initial_color = Colors.blocking_init_color
		_touched_color = Colors.darker(_initial_color)
	else:
		_initial_color = Colors.single_cube_init_color
		_touched_color = Colors.darker(_initial_color)
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color


func reset():
	is_used = false
	_color_changed = false
	update_color()
