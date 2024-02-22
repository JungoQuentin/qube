extends Cube 
class_name LevelGateCube

@export var destination: PackedScene
@export var dependency: PackedScene
var _cannot_go_color
var _can_go_color


func _ready():
	super._ready()
	_can_go_color = _initial_color
	_cannot_go_color = Colors.darker(_initial_color, 1, 0)
	is_gate_open()


func is_gate_open():
	if dependency == null:
		_update_color(true)
		return true
	var is_open = LevelManager.is_level_finished(dependency) or LevelManager.get_current_progression().all_puzzle_unlocked
	_update_color(is_open)
	return is_open


func on_touch():
	_touched_animation_start()
	if is_gate_open():
		await Utils.sleep(0.1)
		LevelManager.goto_level_by_packed(destination)


func _update_color(is_open: bool):
	_initial_color = _can_go_color if is_open else _cannot_go_color
	_touched_color = Colors.darker(_initial_color)
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color
