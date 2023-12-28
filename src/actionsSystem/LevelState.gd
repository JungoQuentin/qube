class_name LevelState

var player_global_transform: Transform3D
var moving_cubes_position: Dictionary
var single_cubes_state: Dictionary
var switch_cubes_state: Dictionary
var living_cubes_position: Dictionary


static func from_level(level: Level):
	return LevelState.new(
		level.player.global_transform,
		Utils.arr_to_dict(level.moving_cubes, func(c): return c.global_transform),
		Utils.arr_to_dict(level.single_use_cubes, func(c): return c.is_used),
		Utils.arr_to_dict(level.switch_cubes, func(c): return c.on),
		Utils.arr_to_dict(level.living_cubes, func(c): return c.global_transform),
	)


func _init(
		_player_global_position: Transform3D,
		_moving_cubes_position: Dictionary,
		_single_cubes_state: Dictionary,
		_switch_cubes_state: Dictionary,
		_living_cubes_position: Dictionary,
	):
	player_global_transform = _player_global_position
	moving_cubes_position = _moving_cubes_position
	single_cubes_state = _single_cubes_state
	switch_cubes_state = _switch_cubes_state
	living_cubes_position = _living_cubes_position


func _to_string():
	return "player_global_position: " + str(player_global_transform)

## Set the level to correspond to this level state
func apply(level: Level):
	level.player.global_transform = player_global_transform
	moving_cubes_position.keys().map(func(cube): cube.global_transform = moving_cubes_position[cube])
	single_cubes_state.keys().map(func(cube): cube.is_used = single_cubes_state[cube]; cube.update_color())
	switch_cubes_state.keys().map(func(cube): cube.on = switch_cubes_state[cube]; cube.update_color())
	living_cubes_position.keys().map(func(cube): cube.global_transform = living_cubes_position[cube])

func is_equal(other: LevelState) -> bool:
	return player_global_transform == other.player_global_transform and \
		moving_cubes_position == other.moving_cubes_position and \
		single_cubes_state == other.single_cubes_state and \
		switch_cubes_state == other.switch_cubes_state and \
		living_cubes_position == other.living_cubes_position
