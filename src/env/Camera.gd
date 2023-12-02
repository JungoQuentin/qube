extends Camera3D

#region DECLARATION

const camera_fov = 30.
const camera_y_dist_by_cube_dimension: Dictionary = {
	3: 9,
	5: 15.,
	7: 20.
}
@onready var _level: Level = get_tree().current_scene
var is_moving = false

#endregion


func _ready():
	fov = camera_fov
	await Utils.wait_while(func(): return _level.map_cube == null)
	position.z = camera_y_dist_by_cube_dimension[_level.map_cube.dimension]
	current = true


func _input(_event):
	if is_moving:
		return
	var input = Utils.is_one_action_pressed(["camera_top", "camera_bottom", "camera_right", "camera_left", "rotate_right", "rotate_left"])
	if not input.is_empty():
		_move(input)


func _move(input: String):
	is_moving = true
	var pivot = Node3D.new()
	_level.add_child(pivot)
	Utils.switch_parent(self, pivot, true)
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
	axis = basis * axis # transform to get in the real "repert"
	var original_basis = pivot.basis
	var goal_basis = pivot.basis.rotated(axis, PI / 2)
	var _tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(func(t): pivot.basis = original_basis.slerp(goal_basis, t), 0., 1., 0.3)
	await _tween.finished
	Utils.switch_parent(self, _level, true)
	pivot.free()
	is_moving = false
