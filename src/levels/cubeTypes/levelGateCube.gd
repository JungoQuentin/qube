extends Cube 
class_name LevelGateCube

@export var gate_to_level_index: int
@export var should_be_finished_level_index: int
var _cannot_go_color
var _can_go_color


func _ready():
	super._ready()
	_can_go_color = _initial_color
	_cannot_go_color = Colors.darker(_initial_color, 1, 0)
	is_gate_open()


func is_gate_open():
	if should_be_finished_level_index < 0 or LevelManager.completed_levels.size() <= should_be_finished_level_index:
		_update_color(true)
		return true
	var is_open = LevelManager.completed_levels[should_be_finished_level_index]
	_update_color(is_open)
	return is_open


func on_touch():
	_touched_animation_start()

	if is_gate_open():
		LevelManager.goto_level_by_index(gate_to_level_index)


func _update_color(is_open: bool):
	_initial_color = _can_go_color if is_open else _cannot_go_color
	_touched_color = Colors.darker(_initial_color)
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color
