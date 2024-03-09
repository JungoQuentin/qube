class_name LevelState extends Savable

var player_global_transform: Transform3D
var moving_cubes_position: Dictionary
var single_cubes_state: Dictionary
var switch_cubes_state: Dictionary
var laser_cubes_state: Dictionary
var hole_cubes_state: Dictionary
var moving_cubes_in_a_hole: Dictionary


static func from_level(level: BaseLevel, for_save:= false):
	return LevelState.new(
		level.player.global_transform,
		Utils.arr_to_dict(level.moving_cubes, func(c): return c.global_transform, func(k): return k.name if for_save else k),
		Utils.arr_to_dict(level.single_use_cubes, func(c): return c.is_used, func(k): return k.name if for_save else k),
		Utils.arr_to_dict(level.switch_cubes, func(c): return c.on, func(k): return k.name if for_save else k),
		Utils.arr_to_dict(level.laser_cubes, func(c): return c.laser_on, func(k): return k.name if for_save else k),
		Utils.arr_to_dict(level.hole_cubes, func(c: HoleCube): return c.filled, func(k): return k.name if for_save else k),
		Utils.arr_to_dict(level.moving_cubes, func(c): return c.in_a_hole, func(k): return k.name if for_save else k),
	)


func _init(
		_player_global_position: Transform3D,
		_moving_cubes_position:= {},
		_single_cubes_state:= {},
		_switch_cubes_state:= {},
		_laser_cubes_state:= {},
		_hole_cubes_state:= {},
		_moving_cubes_in_a_hole:= {},
	):
	player_global_transform = _player_global_position
	moving_cubes_position = _moving_cubes_position
	single_cubes_state = _single_cubes_state
	switch_cubes_state = _switch_cubes_state
	laser_cubes_state = _laser_cubes_state
	hole_cubes_state = _hole_cubes_state
	moving_cubes_in_a_hole = _moving_cubes_in_a_hole

func _to_string():
	return "LevelState { player_global_position: " + str(player_global_transform) + " }"

## Set the level to correspond to this level state
func apply(level: BaseLevel, from_save:= false):
	var get_cube = func(k): return level.find_child(k, true, false) if from_save else k
	level.player.global_transform = player_global_transform
	moving_cubes_position.keys().map(
		func(name):
			get_cube.call(name).global_transform = moving_cubes_position[name]
	)
	single_cubes_state.keys().map(
		func(name):
			get_cube.call(name).is_used = single_cubes_state[name]
			get_cube.call(name).update_color()
	)
	switch_cubes_state.keys().map(
		func(name):
			get_cube.call(name).on = switch_cubes_state[name]
			get_cube.call(name).update_color()
	)
	laser_cubes_state.keys().map(
		func(name):
			get_cube.call(name).laser_on = laser_cubes_state[name]
	)
	hole_cubes_state.keys().map(
		func(name):
			if hole_cubes_state[name]: 
				get_cube.call(name).fill()
	)
	moving_cubes_in_a_hole.keys().map(
		func(name):
			get_cube.call(name).in_a_hole = moving_cubes_in_a_hole[name]
	)

func is_equal(other: LevelState) -> bool:
	return player_global_transform == other.player_global_transform and \
		moving_cubes_position == other.moving_cubes_position and \
		single_cubes_state == other.single_cubes_state and \
		switch_cubes_state == other.switch_cubes_state and \
		laser_cubes_state == other.laser_cubes_state and \
		hole_cubes_state == other.hole_cubes_state and \
		moving_cubes_in_a_hole == other.moving_cubes_in_a_hole
