class_name NaturalCamera extends Camera3D

@onready var _level: Level = get_tree().current_scene
var is_moving = false
var is_op:= false
var locked:= false
const DURATION = 0.3


func _ready():
	fov = Level.CAMERA_FOV
	position.z = Level.CAMERA_DISTANCE


func _process(_delta):
	if locked or not _level.player or not current:
		return
	global_position = _global_pos_zenith_player()
	var camera_up = _level.camera.global_basis * Vector3.UP
	look_at(Vector3.ZERO, camera_up)


func transition_to(goal_camera: Camera3D):
	if locked:
		return
	locked = true
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
	locked = false


func transition_back():
	locked = true
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
	locked = false


func _global_pos_zenith_player() -> Vector3:
	return _level.player.global_position.normalized() * Level.CAMERA_DISTANCE * (-1 if is_op else 1)
