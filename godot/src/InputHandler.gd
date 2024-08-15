# TODO this is not a real solution, but a hacky patch
# if the player input should be blocked when there is a move else where (camera or movingcube)
# there should be another mecanisme to avoid problems
# maybe I want to move the camera when the player is already moving !
 
class_name InputHandler extends Node

var _action_stack: Array[String] = []
@onready var _level: BaseLevel = get_parent()

##
func is_locked() -> bool:
	return not _action_stack.is_empty()

##
func _create_action_name(node: Node) -> String:
	var stack = get_stack()
	if stack.size() < 2:
		return node.name
	return node.name + "_" + get_stack()[2]["source"] + "_" + get_stack()[2]["function"]

##
func _add_action(node: Node) -> bool:
	var action_name = _create_action_name(node)
	if _action_stack.has(action_name):
		UtilsRS.crash(["You cannot add the same action !"])
		return false
	_action_stack.push_back(action_name)
	return true

##
func _end_action(node: Node) -> bool:
	var action_name = _create_action_name(node)
	if not _action_stack.has(action_name):
		UtilsRS.crash(["You cannot end unexisting action !"])
		return false
	_action_stack.remove_at(_action_stack.find(action_name))
	return true

##
func _process(_delta):
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
		
		## security
		var player_face = _level.object_current_face(_level.player)
		if not _level.camera_controller._is_front_face(player_face):
			#UtilsRS.crash(["gatcha !"])
			return
		
		_add_action(_level.player)
		await _level.player.handle_input(player_input)
		_end_action(_level.player)
		return

	## Camera move and rotate
	if get_tree().current_scene is LevelGate:
		return
	var camera_input = Utils.is_one_action_pressed(["camera_top", "camera_bottom", "camera_right", "camera_left", "rotate_right", "rotate_left"])
	if not camera_input.is_empty():
		_add_action(_level.camera_controller)
		await _level.camera_controller.handle_input(camera_input)
		_end_action(_level.camera_controller)
		return

##
func _input(_event):
	if is_locked():
		return
	## Meta (undo, redo, reset)
	var undo_input: String = Utils.is_one_action_pressed(["undo", "redo", "reset"])
	if not undo_input.is_empty():
		_add_action(self)
		await _level.action_system.handle_input(undo_input)
		_end_action(self)
		return
