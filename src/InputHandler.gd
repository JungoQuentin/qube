extends Node

var _locker: Array[String] = []
var _level: Level
var _stack_display_enable = true

##
func is_locked() -> bool:
	return not _locker.is_empty()

##
func _create_action_name(node: Node) -> String:
	return node.name + "_" + get_stack()[2]["source"] + "_" + get_stack()[2]["function"]

##
func _add_action(node: Node) -> bool:
	if is_locked():
		return false
	var action_name = _create_action_name(node)
	if _locker.has(action_name):
		Utils.crash(["You cannot add the same action !"])
		return false
	_locker.push_back(action_name)
	return true

##
func _end_action(node: Node) -> bool:
	var action_name = _create_action_name(node)
	if not _locker.has(action_name):
		Utils.crash(["You cannot end unexisting action !"])
		return false
	_locker.remove_at(_locker.find(action_name))
	return true

##
func _process(_delta):
	if _level == null:
		return
	_level.update_locker_display()
	if is_locked():
		return
	
	## Player move
	var player_input = Utils.is_one_action_pressed(["player_top", "player_bottom", "player_right", "player_left"])
	if not player_input.is_empty():
		if not _level.camera_controller.is_in_player_mode():
			_add_action(_level.camera_controller)
			await _level.camera_controller.player_want_to_move()
			_end_action(_level.camera_controller)
			return
		_add_action(_level.player)
		await _level.player.handle_input(player_input)
		_end_action(_level.player)
		return

	## Camera move and rotate
	var camera_input = Utils.is_one_action_pressed(["camera_top", "camera_bottom", "camera_right", "camera_left", "rotate_right", "rotate_left"])
	if not camera_input.is_empty():
		_add_action(_level.camera_controller)
		await _level.camera_controller.handle_input(camera_input)
		_end_action(_level.camera_controller)
		return
	
	## Meta (undo, redo, reset)
	var undo_input: String = Utils.is_one_action_pressed(["undo", "redo", "reset"])
	if not undo_input.is_empty():
		_add_action(self)
		await ActionSystem.handle_input(undo_input)
		_end_action(self)
		return
