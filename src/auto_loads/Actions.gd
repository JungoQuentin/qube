extends Node

var actions: Array[ActionNode] = []
var undo_stack: Array[ActionNode] = []

func _input(_event):
	if Input.is_action_just_pressed("undo"):
		undo()
	if Input.is_action_just_pressed("redo"):
		redo()
	if Input.is_action_just_pressed("reset"):
		reset_level()
	if Input.is_action_just_pressed("settings"):
		settings()

func reset_level():
	add(ActionNode.Type.RESET, ActionNode.State.new(Global.player.position, Global.map_cube.basis))
	Global.map_cube.reset()
	Global.player.reset()

func undo():
	if actions.size() == 0:
		return
	var last_action = actions.pop_back()
	last_action.undo()

func redo():
	if undo_stack.size() == 0:
		return
	var last_action = undo_stack.pop_back()
	last_action.redo()

func add(type, state, clear_undo_stack=true):
	if clear_undo_stack:
		undo_stack.clear()
	actions.push_back(ActionNode.new(type, state))


func settings():
	pass

# IDEE: avec les trigger arriere, faire pivot le a 90 degres sur l'axe y pour changer de point de vu ?
