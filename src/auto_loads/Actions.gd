extends Node

var actions: Array[ActionNode] = []

func _print():
	print(actions.size(), " actions")
	for action in actions:
		print(ActionNode.Type.keys()[action.type])

func _input(_event):
	if Input.is_action_just_pressed("redo"):
		pass
	if Input.is_action_just_pressed("reset"):
		reset_level()
	if Input.is_action_just_pressed("undo"):
		undo()
	if Input.is_action_just_pressed("settings"):
		pass

func reset_level():
	Global.map_cube.reset()
	Global.player.reset()
	add(ActionNode.Type.RESET, null) # TODO

func undo():
	if actions.size() == 0:
		return
	var last_action = actions.pop_back()
	last_action.undo()

func redo():
	pass

func add(type, action):
	actions.push_back(ActionNode.new(type, action))



# IDEE: avec les trigger arriere, faire pivot le a 90 degres sur l'axe y pour changer de point de vu ?
