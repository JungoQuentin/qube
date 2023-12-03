class_name MyCamera extends Camera3D

#region DECLARATION

const camera_fov = 30.
const camera_y_dist_by_cube_dimension: Dictionary = {
	3: 9,
	5: 15.,
	7: 20.
}
@onready var _level: Level = get_tree().current_scene
var is_moving = false
var global_transform_front_to_player: Transform3D

#endregion


func _ready():
	fov = camera_fov
	await Utils.wait_while(func(): return _level.map_cube == null)
	position.z = camera_y_dist_by_cube_dimension[_level.map_cube.dimension]
	current = true
	global_transform_front_to_player = global_transform


func _input(_event):
	if is_moving:
		return
	var input = Utils.is_one_action_pressed(["camera_top", "camera_bottom", "camera_right", "camera_left", "rotate_right", "rotate_left"])
	if not input.is_empty():
		_input_move(input)


func has_moved_away_from_player()-> bool:
	return global_transform.origin != global_transform_front_to_player.origin


func go_to_player():
	is_moving = true
	global_transform = global_transform_front_to_player
	# TODO nice animation
	await Utils.sleep(0.3)
	is_moving = false


func player_move(direction: Vector3, floor_direction):
	await _move(direction.cross(floor_direction))
	global_transform_front_to_player = global_transform


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
