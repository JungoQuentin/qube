class_name ActionNode

class State:
	var player_position: Vector3
	var map_basis: Basis
	var moving_cubes_position
	var single_cubes_state

	func _init(_player_position, _map_basis, _moving_cubes_position, _single_cubes_state):
		player_position = _player_position
		map_basis = _map_basis
		moving_cubes_position = _moving_cubes_position
		single_cubes_state = _single_cubes_state

enum Type {	MOVE, RESET, PUSH }

var type: ActionNode.Type
var state: State 

func _init(_state: State, _type: Type):
	type = _type
	state = _state

func _set_to_state():
	Global.map_cube.basis = state.map_basis
	Global.player.position = state.player_position 
	state.moving_cubes_position.keys().map(func(cube): cube.position = state.moving_cubes_position[cube])
	state.single_cubes_state.keys().map(func(cube): cube.is_used = state.single_cubes_state[cube]; cube.update_color())

########## UNDO ###########

func undo():
	if Global.player.is_moving:
		_abort_moving()
	else:
		_undo()

func _undo():
	Actions.add_action(type, true)
	_set_to_state()

func _abort_moving():
	if Global.map_cube.is_rotating: # en plus du player qui roll
		Global.map_cube.stop_rotation()
		Global.map_cube.basis = Global.map_cube.start
	Global.player.reset_pivot()
	Global.player.is_moving = false

###### REDO ###########

func redo():
	Actions.add_action(type)
	_set_to_state()
