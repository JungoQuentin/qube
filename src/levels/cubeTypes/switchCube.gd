extends Cube
class_name SwitchCube

var on: bool = false 
var _on_color: Color
var _off_color: Color

func _ready():
	super._ready()
	_on_color =  Colors.switch_cube_on_color
	_off_color = Colors.switch_cube_off_color
	_mesh_instance.get_surface_override_material(0).albedo_color = _on_color if on else _off_color 


func on_touch():
	on = not on
	_switch_animation_start()
	get_tree().current_scene.check_all_switch_state()


func _switch_animation_start():
	if _touch_tween_running():
		_touch_tween.kill()
	var material = _mesh_instance.get_surface_override_material(0)
	_touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	_touch_tween.tween_property(material, "albedo_color", _on_color if on else _off_color , 0.1)
	_touch_tween.tween_callback(func(): _touch_tween.kill())
