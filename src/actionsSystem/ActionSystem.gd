## handles the undo/redo/reset system
class_name ActionSystem

var _level: BaseLevel
var state_stack: Array[LevelState]
var current_state_index: int = 0


func _init(level: BaseLevel):
	_level = level
	state_stack.push_back(LevelState.from_level(_level))


func handle_input(input: String):
	match input:
		"undo":
			await _undo()
		"redo":
			await _redo()
		"reset":
			await _reset_level()


func _undo():
	await _level.abort_move()
	if current_state_index == 0:
		return
	current_state_index -= 1
	state_stack[current_state_index].apply(_level)
	await _level.camera_controller.after_meta()


func _redo():
	if current_state_index + 1 >= state_stack.size():
		return
	state_stack[current_state_index + 1].apply(_level)
	current_state_index += 1
	await _level.camera_controller.after_meta()


func _reset_level():
	if _level is LevelGate:
		Utils.unimplemented("reset dans le level gate")
		return
	_level.get_tree().reload_current_scene()
	return # TODO this is the nice way, where you can undo a reset
	await _level.abort_move()
	if current_state_index == 0:
		return
	_add_state(state_stack.front())
	state_stack.front().apply(_level)
	await _level.camera_controller.after_meta()
	current_state_index = state_stack.size() - 1
	_remove_redo()
	current_state_index = state_stack.size() - 1


func player_start_move():
	current_state_index += 1
	_remove_redo()

func player_start_push():
	current_state_index += 1
	_remove_redo()

func player_end_move():
	_add_state(LevelState.from_level(_level))
	current_state_index = state_stack.size() - 1

func player_end_push():
	_add_state(LevelState.from_level(_level))
	current_state_index = state_stack.size() - 1


func _remove_redo():
	if state_stack.size() > current_state_index:
		state_stack = state_stack.slice(0, current_state_index)


func _add_state(state: LevelState) -> bool:
	if not state.is_equal(state_stack.back()):
		state_stack.push_back(state)
		return true
	return false


#region DEBUG
var last_state_stack_size = 0
var last_current_state_index = 0
func _process(_delta):
	if last_state_stack_size != state_stack.size() or last_current_state_index != current_state_index:
		_level.update_stack_display()
	last_state_stack_size = state_stack.size()
	last_current_state_index = current_state_index
#endregion
