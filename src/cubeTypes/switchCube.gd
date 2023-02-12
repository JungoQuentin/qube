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
	cube_type = SWITCH

func on_touch():
	on = not on
	_switch_animation_start()
	Global.check_all_switch_state()

func _switch_animation_start():
	var _tmp_mesh = mesh_instance.mesh.duplicate(true)
	mesh_instance.mesh = _tmp_mesh
	var _material = _tmp_mesh.surface_get_material(0)
	if tween:
		tween.pause()
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_material, "albedo_color", on_color if on else off_color , 0.1)
	tween.tween_callback(func(): tween = null)
	tween.play()
