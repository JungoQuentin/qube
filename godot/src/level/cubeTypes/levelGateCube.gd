extends Cube 
class_name LevelGateCube

@export var destination: PackedScene
@export var dependency: PackedScene
var _disabled_color
var _enabled_color
var _won_color

signal player_touch


func _ready():
	super._ready()
	_enabled_color = _initial_color
	_disabled_color = ColorSet.darker(_initial_color, 1, 0)
	_won_color = _color_set.gate_won_color
	is_gate_open()


func is_gate_open() -> bool:
	if dependency == null:
		update_color(true)
		return true
	var is_open = LevelManager.is_level_finished(dependency) or LevelManager.get_current_progression().all_puzzle_unlocked
	update_color(is_open)
	return is_open


func on_touch():
	super.on_touch()
	player_touch.emit()


func update_color(can_win: bool):
	if _touch_tween and _touch_tween.is_valid():
		_touch_tween.kill()
	if destination and LevelManager.is_level_finished(destination):
		_initial_color = _won_color
	elif can_win:
		_initial_color = _enabled_color
	else:
		_initial_color = _disabled_color
	_touched_color = ColorSet.darker(_initial_color)
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color
