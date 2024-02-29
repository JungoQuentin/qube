extends Cube 
class_name EndCube


var _disabled_color
var _enabled_color
signal player_touch


func _ready():
	super._ready()
	_enabled_color = _initial_color
	_disabled_color = Colors.darker(_initial_color, 1, 0)


func on_touch():
	super.on_touch()
	player_touch.emit()


func update_color(can_win: bool):
	if _touch_tween and _touch_tween.is_valid():
		_touch_tween.kill()
	_initial_color = _enabled_color if can_win else _disabled_color
	_touched_color = Colors.darker(_initial_color)
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color
