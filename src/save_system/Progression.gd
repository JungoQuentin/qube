class_name Progression extends Savable

var global_position_entry_point: Transform3D
var completed_levels: Array#[String]
var all_puzzle_unlocked: bool

func _init(
	_global_position_entry_point:= Transform3D.IDENTITY,
	_completed_levels:= [],
	_all_puzzle_unlocked:= false
):
	global_position_entry_point = _global_position_entry_point
	completed_levels = _completed_levels
	all_puzzle_unlocked = _all_puzzle_unlocked
