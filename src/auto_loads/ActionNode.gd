class_name ActionNode

class State:
	var player_position: Vector3
	var map_basis: Basis

	func _init(_player_position, _map_basis):
		player_position = _player_position
		map_basis = _map_basis

enum Type {
	MOVE,
	RESET,
	UNDO,
	#REDO,
}

var type: ActionNode.Type
var state: State 

func _init(_type: ActionNode.Type, _state: State):
	type = _type
	state = _state

########## UNDO ###########

func undo():
	match type:
		Type.MOVE:
			_undo_moving()
		Type.RESET:
			_undo_reset()

func _undo_moving():
	if not Global.player.is_rolling:
		Actions.undo_stack.push_back(ActionNode.new(Type.UNDO, State.new(Global.player.position, Global.map_cube.basis)))
		Global.map_cube.basis = state.map_basis
		Global.player.position = state.player_position 
		return

	if Global.map_cube.is_rotating: # en plus du player qui roll
		Global.map_cube.stop_rotation(false)
		Global.map_cube.basis = Global.map_cube.start
	Global.player.reset_pivot()
	Global.player.is_rolling = false

func _undo_reset():
	if Global.player.is_rolling or Global.map_cube.is_rotating:
		Log.crash("Ce n'est pas possible de undo un reset, alors que le player bouge, wtf")
	Actions.undo_stack.push_back(ActionNode.new(Type.UNDO, State.new(Global.player.position, Global.map_cube.basis)))
	Global.map_cube.basis = state.map_basis
	Global.player.position = state.player_position 

###### REDO ###########

func redo():
	Actions.add(Type.MOVE, State.new(Global.player.position, Global.map_cube.basis), false)
	Global.player.position = state.player_position
	Global.map_cube.basis = state.map_basis
