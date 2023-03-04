class_name Action

enum Type {	MOVE, RESET, PUSH }

var type: Action.Type
var state: LevelState 

func _init(_state: LevelState, _type: Type):
	type = _type
	state = _state

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

########## set state ##########

## Set the level to correspond to the state of the action
func _apply_level_state():
	Level.map_cube.basis = state.map_basis
	Level.player.position = state.player_position 
	state.moving_cubes_position.keys().map(func(cube): cube.position = state.moving_cubes_position[cube])
	state.single_cubes_state.keys().map(func(cube): cube.is_used = state.single_cubes_state[cube]; cube.update_color())

########## UNDO ##########

func undo():
	if Level.player.is_moving or Level.map_cube.is_moving:
		Level.player.abort_move()
		Level.map_cube.abort_rotation()
	else:
		ActionSystem.add_action(type, true)
		_apply_level_state()


###### REDO ###########

func redo():
	ActionSystem.add_action(type)
	_apply_level_state()
