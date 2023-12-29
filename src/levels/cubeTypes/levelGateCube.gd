extends Cube 
class_name LevelGateCube

@export var gate_to_level_index: int
@export var should_be_finished_level_index: int
var _cannot_go_color
var _can_go_color
var gate_open:= false:
	set(_gate_open):
		gate_open = _gate_open
		_update_color()



func _ready():
	super._ready()
	_can_go_color = _initial_color
	_cannot_go_color = Colors.darker(_initial_color, 1, 0)
	gate_open = true
	_update_color()


func on_touch():
	_touched_animation_start()
	print(gate_open)
	if gate_open:
		LevelManager.goto_level_by_index(gate_to_level_index)


func _update_color():
	_initial_color = _can_go_color if gate_open else _cannot_go_color
	_touched_color = Colors.darker(_initial_color)
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color
