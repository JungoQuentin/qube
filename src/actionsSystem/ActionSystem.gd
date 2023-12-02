## AutoLoad that handles the undo/redo/reset system
extends Node

var _level
var actions: Array[Action] = []
var undo_stack: Array[Action] = []

func _input(_event):
	_input_ingame()
	# if Level.game_state == Level.INGAME: TODO
	# 	_input_ingame()
	# if Level.game_state == Level.PAUSE:
	# 	pass
	# if Level.game_state == Level.MENU:
	# 	pass
	_level = get_tree().current_scene # TODO + opti ? -> just use get_tree().current_scene

func _input_ingame():
	var action_str: String = Utils.is_one_action_pressed(["undo", "redo", "reset", "settings"])
	if action_str.is_empty():
		return
	# TODO : just if an other is pressed ? -> sinon block avec les is_moving ?
	#if not Utils.is_one_action_pressed(["top", "bottom", "left", "right"]).is_empty():
	#	return
	match action_str:
		"undo":
			_undo()
		"redo":
			_redo()
		"reset":
			_reset_level()
		"settings":
			_settings()

func _undo():
	if await _level.player.abort_move():
		return
	if actions.is_empty():
		return
	actions.pop_back().undo()

func _redo():
	if undo_stack.is_empty():
		return
	undo_stack.pop_back().redo()

func _reset_level():
	if actions.is_empty() or actions[actions.size() - 1].type == Action.Type.RESET:
		return
	if not _level.player.is_moving:
		add_action(Action.Type.RESET)
	undo_stack.clear()
	_level.map_cube.reset()
	_level.player.reset()
	_level.moving_cubes.map(func(cube): cube.reset())
	_level.single_use_cubes.map(func(cube): cube.reset())

func _settings():
	pass

func add_action(_type=Action.Type.MOVE,
		_to_undo=false,
		_player_position=_level.player.position,
		_map_basis=_level.map_cube.basis,
		_move_cubes_position={},
		_single_cubes_state={}):
	if _move_cubes_position.is_empty():
		_level.moving_cubes.map(func(cube): _move_cubes_position[cube] = cube.position)
	if _single_cubes_state.is_empty():
		_level.single_use_cubes.map(func(cube): _single_cubes_state[cube] = cube.is_used)
	var action = Action.new(
			LevelState.new(
					_player_position,
					_map_basis,
					_move_cubes_position,
					_single_cubes_state), _type, _level)
	(undo_stack if _to_undo else actions).push_back(action)


# DEBUG
var last_actions_size = 0
var last_undo_stack_size = 0
func _process(_delta):
	if last_actions_size != actions.size() or last_undo_stack_size != undo_stack.size():
		_level.update_stack_display()
	last_actions_size = actions.size()
	last_undo_stack_size = undo_stack.size()
