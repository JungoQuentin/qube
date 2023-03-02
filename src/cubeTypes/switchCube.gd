extends Cube
class_name SwitchCube

var on: bool = false 
var on_color: Color
var off_color: Color

func _ready():
	super._ready()
	on_color =  Colors.switch_cube_on_color
	off_color = Colors.switch_cube_off_color
	mesh.surface_get_material(0).albedo_color = on_color if on else off_color 

func on_touch(_direction: Vector3, _cube):
	on = not on
	_switch_animation_start()
	Global.check_all_switch_state()

func _switch_animation_start():
	var _tmp_mesh = mesh_instance.mesh.duplicate(true)
	mesh_instance.mesh = _tmp_mesh
	var _material = _tmp_mesh.surface_get_material(0)
	if touch_tween:
		touch_tween.pause()
		touch_tween.kill()
	touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	touch_tween.tween_property(_material, "albedo_color", on_color if on else off_color , 0.1)
	touch_tween.tween_callback(func(): touch_tween = null)
	touch_tween.play()
