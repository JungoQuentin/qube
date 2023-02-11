class_name ActionNode

enum Type {
	SIMPLE_MOVE,
	PLAYER_AND_MAP_MOVE,
	RESET,
	UNDO,
	REDO,
}

var type: ActionNode.Type
var action

func _init(_type: ActionNode.Type, _action):
	type = _type
	action = _action

func undo():
	match type:
		Type.SIMPLE_MOVE:
			if Global.player.is_rolling:
				_undo_moving()
			else:
				print(action)
				_undo_simple_move(action)
		Type.PLAYER_AND_MAP_MOVE:
			if Global.player.is_rolling:
				_undo_moving()
			else:
				_undo_player_and_map_move(action[2], action[1])
		Type.RESET:
			pass
		Type.UNDO:
			pass
		Type.REDO:
			pass


func _undo_moving():
	if Global.map_cube.is_rotating:
		Global.map_cube.stop_rotation(false)
		Global.map_cube.basis = Global.map_cube.start
	Global.player.reset_pivot()
	Global.player.is_rolling = false

func _undo_simple_move(direction):
	Global.player.position -= direction
	
func _undo_player_and_map_move(player_position, basis):
	Global.map_cube.basis = basis
	Global.player.position = player_position