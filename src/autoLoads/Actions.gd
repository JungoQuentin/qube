extends Node

var actions: Array[ActionNode] = []
var undo_stack: Array[ActionNode] = []

func _process(_delta):
	match Global.game_state:
		Global.INGAME:
			if Input.is_action_just_pressed("undo"): _undo()
			if Input.is_action_just_pressed("redo"): _redo()
			if Input.is_action_just_pressed("reset"): _reset_level()
			if Input.is_action_just_pressed("settings"): settings()
		Global.PAUSE:
			pass
		Global.MENU:
			pass

func _undo():
	if actions.size() == 0: return
	actions.pop_back().undo()

func _redo():
	if undo_stack.size() == 0: return
	undo_stack.pop_back().redo()

func _reset_level():
	if actions[actions.size() - 1].type == ActionNode.Type.RESET:
		return
	if not Global.player.is_moving:
		add_action(ActionNode.Type.RESET)
	undo_stack.clear()
	Global.map_cube.reset()
	Global.player.reset()
	Global.moving_cubes.map(func(cube): cube.reset())
	Global.single_use_cubes.map(func(cube): cube.reset())

func settings():
	pass

func add_action(_type=ActionNode.Type.MOVE,
		_to_undo=false,
		_player_position=Global.player.position,
		_map_basis=Global.map_cube.basis,
		_move_cubes_position={},
		_single_cubes_state={}):
	if _move_cubes_position.is_empty():
		Global.moving_cubes.map(func(cube): _move_cubes_position[cube] = cube.position)
	if _single_cubes_state.is_empty():
		Global.single_use_cubes.map(func(cube): _single_cubes_state[cube] = cube.is_used)
	var action = ActionNode.new(
			ActionNode.State.new(
					_player_position,
					_map_basis,
					_move_cubes_position,
					_single_cubes_state), _type)
	(undo_stack if _to_undo else actions).push_back(action)
