extends Node3D
class_name MapCube

@export var dimension: int = 0
var is_moving = false
var _move_logic: MoveLogic

func _ready():
	if dimension == 0:
		Log.crash("dimension not set !!")
	Global.map_cube = self

func start_cube_rotation(direction: Vector3):
	_move_logic = MoveLogic.new(self, direction).init_map_rotation()
	Utils.switch_parent(Global.player, _move_logic._rotator)
	Global.moving_cubes.map(func(cube): Utils.switch_parent(cube, _move_logic._rotator, true))
	await _move_logic.map_rotate()
	if is_moving:
		stop_rotation()

func stop_rotation():
	Utils.switch_parent(Global.player, get_parent())
	Global.moving_cubes.map(func(cube): Utils.switch_parent(cube, get_parent(), true); cube.replace_after_map_rotation())
	_move_logic._rotator.queue_free()
	is_moving = false

func reset():
	if is_moving:
		stop_rotation()
	transform = Transform3D.IDENTITY
