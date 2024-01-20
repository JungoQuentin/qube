class_name NaturalCamera extends Camera3D

@onready var _level: Level = get_tree().current_scene
var _is_moving:= ""
const DURATION = 0.3


func _ready():
	fov = Level.CAMERA_FOV
	position.z = Level.CAMERA_DISTANCE


func _process(_delta):
	if not _is_moving.is_empty() or not _level.player or not current:
		return
	global_position = _global_pos_zenith_player()
	var camera_up = _level.camera.global_basis * Vector3.UP
	look_at(Vector3.ZERO, camera_up)


## Not "locked safe" 
## Called by the fixed camera
func transition_to(goal_camera: Camera3D):
	if not _is_moving.is_empty():
		Utils.crash(["Already moving", _is_moving])
	_set_moving()
	var tween = create_tween()
	var start_basis = basis
	var start_position = position
	tween.tween_method(
		func(t):
			position = start_position.slerp(goal_camera.position, t)
			basis = start_basis.slerp(goal_camera.basis, t)
			look_at(Vector3.ZERO, basis * Vector3.UP)
			,
		0., 1., DURATION)
	await tween.finished
	_is_moving = ""


func transition_back():
	if not _is_moving.is_empty():
		Utils.crash(["Already moving", _is_moving])
	_set_moving()
	var goal = _global_pos_zenith_player()
	var tween = create_tween()
	var start_basis = basis
	var start_position = position
	tween.tween_method(
		func(t):
			position = start_position.slerp(goal, t)
			basis = start_basis.slerp(_level.camera.basis, t)
			look_at(Vector3.ZERO, basis * Vector3.UP)
			,
		0., 1., DURATION)
	await tween.finished
	_is_moving = ""


func _global_pos_zenith_player() -> Vector3:
	return _level.player.global_position.normalized() * Level.CAMERA_DISTANCE


func _set_moving():
	_is_moving += "|"
	for s in get_stack():
		_is_moving += " < " + s["function"]
