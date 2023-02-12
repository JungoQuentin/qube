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
	if not Global.player.is_rolling:
		add_action(Global.player.position, Global.map_cube.basis)
	undo_stack.clear()
	Global.map_cube.reset()
	Global.player.reset()


func settings():
	pass

func add_action(_player_position, _map_basis):
	actions.push_back(ActionNode.new(ActionNode.State.new(_player_position, _map_basis)))

func add_undo(_player_position, _map_basis):
	undo_stack.push_back(ActionNode.new(ActionNode.State.new(_player_position, _map_basis)))


# IDEE: avec les trigger arriere, faire pivot le a 90 degres sur l'axe y pour changer de point de vu ?
