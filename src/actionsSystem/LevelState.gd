class_name LevelState

var player_position: Vector3
var map_basis: Basis
var moving_cubes_position: Dictionary
var single_cubes_state: Dictionary

func _init(_player_position: Vector3, _map_basis: Basis, _moving_cubes_position: Dictionary, _single_cubes_state: Dictionary):
	player_position = _player_position
	map_basis = _map_basis
	moving_cubes_position = _moving_cubes_position
	single_cubes_state = _single_cubes_state

func _to_string():
	return "player_position: " + str(player_position)