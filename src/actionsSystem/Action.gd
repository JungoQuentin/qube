class_name Action

enum Type {	MOVE, RESET, PUSH }

var type: Action.Type
var state: LevelState 
var level: Level

func _init(_state: LevelState, _type: Type, _level: Level):
	type = _type
	state = _state
	level = _level

func _to_string():
	var type_str: String
	match type:
		Action.Type.MOVE:
			type_str = "MOVE"
		Action.Type.RESET:
			type_str = "RESET"
		Action.Type.PUSH:
			type_str = "PUSH"
		_:
			type_str = "UNKNOWN"
	return "Action of type {} - with state {}".format([type_str, str(state)], '{}')

## Set the level to correspond to the state of the action
func _apply_level_state():
	level.map_cube.basis = state.map_basis
	level.player.position = state.player_position 
	state.moving_cubes_position.keys().map(func(cube): cube.position = state.moving_cubes_position[cube])
	state.single_cubes_state.keys().map(func(cube): cube.is_used = state.single_cubes_state[cube]; cube.update_color())

## Set the level to correspond to the state of the action and add the action to the undo stack
func undo():
	ActionSystem.add_action(type, true)
	_apply_level_state()

## Set back the level to correspond to the state of the action and add the action to the action stack
func redo():
	ActionSystem.add_action(type)
	_apply_level_state()
