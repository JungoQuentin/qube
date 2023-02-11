extends Node

class Action:
	func _init():
		pass

var actions: Array[Action] = []

func _input(_event):
	if Input.is_action_just_pressed("redo"):
		print("redo")
	if Input.is_action_just_pressed("reset"):
		print("reset")
		reset_level()
	if Input.is_action_just_pressed("undo"):
		print("undo")
	if Input.is_action_just_pressed("settings"):
		print("settings")

func redo():
	pass

func undo():
	pass

func reset_level():
	Global.map_cube.reset()
	Global.player.reset()

# IDEE: avec les trigger arriere, faire pivot le a 90 degres sur l'axe y pour changer de point de vu ?