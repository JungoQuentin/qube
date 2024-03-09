class_name Progression extends Savable

var entry_point_state: LevelState
var completed_levels: Array#[String]
var all_puzzle_unlocked: bool

func _init(
	_entry_point_state:= LevelState.new(Transform3D(Basis.IDENTITY, LevelGate.INITIAL_USER_POSITION), {}, {}, {}, {}),
	_completed_levels:= [],
	_all_puzzle_unlocked:= false
):
	entry_point_state = _entry_point_state
	completed_levels = _completed_levels
	all_puzzle_unlocked = _all_puzzle_unlocked
