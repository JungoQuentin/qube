extends Cube 
class_name EndCube


var _cannot_win_color
var _can_win_color
signal player_touch(_can_win: bool)


var can_win:= false:
	set(_can_win):
		can_win = _can_win
		_update_color()


func _ready():
	super._ready()
	_can_win_color = _initial_color
	_cannot_win_color = Colors.darker(_initial_color, 1, 0)
	_update_color()


func on_touch():
	super.on_touch()
	player_touch.emit(can_win)


func _update_color():
	if _touch_tween and _touch_tween.is_valid():
		_touch_tween.kill()
	_initial_color = _can_win_color if can_win else _cannot_win_color
	_touched_color = Colors.darker(_initial_color)
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color
