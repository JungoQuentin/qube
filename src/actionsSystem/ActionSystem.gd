## AutoLoad that handles the undo/redo/reset system
extends Node

var actions: Array[Action] = []
var undo_stack: Array[Action] = []

func _input(_event):
	if Level.game_state == Level.INGAME and not Utils.is_one_action_pressed(["undo", "redo", "reset", "settings"]).is_empty():
		Level.player.abort_move() # TODO laisser ici, donc aussi pour les settings ?
		if Input.is_action_just_pressed("undo"):
			_undo()
		if Input.is_action_just_pressed("redo"):
			_redo()
		if Input.is_action_just_pressed("reset"):
			_reset_level()
		if Input.is_action_just_pressed("settings"):
			settings()
	if Level.game_state == Level.PAUSE:
		pass
	if Level.game_state == Level.MENU:
		pass

func _undo():
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
	if not Level.player.is_moving:
		add_action(Action.Type.RESET)
	undo_stack.clear()
	Level.map_cube.reset()
	Level.player.reset()
	Level.moving_cubes.map(func(cube): cube.reset())
	Level.single_use_cubes.map(func(cube): cube.reset())

func settings():
	pass

func add_action(_type=Action.Type.MOVE,
		_to_undo=false,
		_player_position=Level.player.position,
		_map_basis=Level.map_cube.basis,
		_move_cubes_position={},
		_single_cubes_state={}):
	if _move_cubes_position.is_empty():
		Level.moving_cubes.map(func(cube): _move_cubes_position[cube] = cube.position)
	if _single_cubes_state.is_empty():
		Level.single_use_cubes.map(func(cube): _single_cubes_state[cube] = cube.is_used)
	var action = Action.new(
			LevelState.new(
					_player_position,
					_map_basis,
					_move_cubes_position,
					_single_cubes_state), _type)
	(undo_stack if _to_undo else actions).push_back(action)


# DEBUG
var last_actions_size = 0
var last_undo_stack_size = 0
func _process(_delta):
	if last_actions_size != actions.size() or last_undo_stack_size != undo_stack.size():
		Level.update_stack_display()
	last_actions_size = actions.size()
	last_undo_stack_size = undo_stack.size()
