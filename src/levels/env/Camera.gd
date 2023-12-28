class_name MyCamera extends Camera3D

const camera_fov = 30.
@onready var _level: Level = get_tree().current_scene
var is_moving = false


func _ready():
	fov = camera_fov
	position.z = 18.5
	current = true


func _input(_event):
	if is_moving or _level.player.is_moving:
		return
	var input = Utils.is_one_action_pressed(["camera_top", "camera_bottom", "camera_right", "camera_left", "rotate_right", "rotate_left"])
	if not input.is_empty():
		_input_move(input)


func is_front_player() -> bool:
	return global_position.normalized() == _level.object_current_face(_level.player)


func go_to_player():
	is_moving = true
	var player_face = _level.object_current_face(_level.player)
	if player_face + global_position.normalized() == Vector3.ZERO:
		if player_face == Vector3.UP or player_face == Vector3.DOWN:
			await _move(global_position.normalized().cross(Vector3.RIGHT))
		else:
			await _move(global_position.normalized().cross(Vector3.UP))
	await _move(global_position.normalized().cross(player_face))
	is_moving = false


func player_move(direction: Vector3, floor_direction):
	await _move(direction.cross(floor_direction))


func _input_move(input: String):
	var axis: Vector3
	match input:
		"camera_bottom":
			axis = Vector3.RIGHT
		"camera_right":
			axis = Vector3.UP
		"camera_left":
			axis = Vector3.DOWN
		"camera_top":
			axis = Vector3.LEFT
		"rotate_left":
			axis = Vector3.FORWARD
		"rotate_right":
			axis = Vector3.BACK
	_move(basis * axis)


func _move(axis: Vector3):
	is_moving = true
	var pivot = Node3D.new()
	_level.add_child(pivot)
	Utils.switch_parent(self, pivot, true)
	var original_basis = pivot.basis
	var goal_basis = pivot.basis.rotated(axis, PI / 2)
	var _tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(func(t): pivot.basis = original_basis.slerp(goal_basis, t), 0., 1., 0.3)
	await _tween.finished
	Utils.switch_parent(self, _level, true)
	pivot.free()
	is_moving = false
