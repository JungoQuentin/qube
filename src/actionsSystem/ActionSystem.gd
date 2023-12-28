## AutoLoad that handles the undo/redo/reset system
extends Node

var _level: Level
var state_stack: Array[LevelState] = []
var current_state_index: int = 0


func start_level(level: Level):
	_level = level
	state_stack.push_back(LevelState.from_level(_level))


func _input(_event):
	var action_str: String = Utils.is_one_action_pressed(["undo", "redo", "reset"])
	if action_str.is_empty():
		return
	{ "undo": _undo, "redo": _redo, "reset": _reset_level }[action_str].call()


func _undo():
	await _level.abort_move()
	if current_state_index == 0:
		return
	current_state_index -= 1
	state_stack[current_state_index].apply(_level)


func _redo():
	if _level.player.is_moving or _level.camera.is_moving:
		return
	if current_state_index + 1 >= state_stack.size():
		return
	state_stack[current_state_index + 1].apply(_level)
	current_state_index += 1


func _reset_level():
	await _level.abort_move()
	#_remove_redo()
	state_stack.push_back(state_stack.front())
	current_state_index += 1
	state_stack.front().apply(_level)


func player_start_move():
	current_state_index += 1
	_remove_redo()


func player_end_move():
	state_stack.push_back(LevelState.from_level(_level))


func _remove_redo():
	if state_stack.size() > current_state_index:
		state_stack = state_stack.slice(0, current_state_index)


func _add_state(state: LevelState):
	state_stack.push_back(state)


#region DEBUG
var last_state_stack_size = 0
var last_current_state_index = 0
func _process(_delta):
	if last_state_stack_size != state_stack.size() or last_current_state_index != current_state_index:
		_level.update_stack_display()
	last_state_stack_size = state_stack.size()
	last_current_state_index = current_state_index
#endregion
