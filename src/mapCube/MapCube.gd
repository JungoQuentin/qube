extends Node3D
class_name MapCube

@export var dimension: int = 0
var is_moving = false
var _move_logic: MapMoveLogic

func _ready():
	if dimension == 0:
		Log.crash("dimension not set !!")

func start_cube_rotation(direction: Vector3):
	_move_logic = MapMoveLogic.new(self, direction).init_map_rotation()
	await _move_logic.map_rotate()
	if is_moving:
		stop_rotation()

func stop_rotation():
	Utils.switch_parent(get_parent().player, get_parent())
	get_parent().moving_cubes.map(func(cube): Utils.switch_parent(cube, get_parent(), true); cube.replace_after_map_rotation())
	_move_logic._rotator.queue_free()
	is_moving = false

func abort_rotation():
	if not is_moving:
		return
	_move_logic._pivot.basis = _move_logic._start
	_move_logic._rotator.basis = _move_logic._rotator_start
	stop_rotation()

func reset():
	if is_moving:
		stop_rotation()
	transform = Transform3D.IDENTITY
