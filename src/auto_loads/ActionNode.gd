class_name ActionNode

class State:
	var player_position: Vector3
	var map_basis: Basis

	func _init(_player_position, _map_basis):
		player_position = _player_position
		map_basis = _map_basis

enum Type {	MOVE, RESET }

#var type: ActionNode.Type
var state: State 

func _init(_state: State):
	#type = _type
	state = _state

func _set_to_state():
	Global.map_cube.basis = state.map_basis
	Global.player.position = state.player_position 

########## UNDO ###########

func undo():
	if Global.player.is_moving:
		_undo_moving()
	else:
		_easy_undo()

func _easy_undo():
	Actions.add_undo(Global.player.position, Global.map_cube.basis)
	_set_to_state()

func _undo_moving():
	if Global.map_cube.is_rotating: # en plus du player qui roll
		Global.map_cube.stop_rotation()
		Global.map_cube.basis = Global.map_cube.start
	Global.player.reset_pivot()
	Global.player.is_moving = false

###### REDO ###########

func redo():
	Actions.add_action(Global.player.position, Global.map_cube.basis)
	_set_to_state()
