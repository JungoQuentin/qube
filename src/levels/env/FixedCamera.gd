class_name FixedCamera extends Camera3D

@onready var _level: Level = get_tree().current_scene
var _is_moving = false
var last_face: Vector3
const DURATION = 0.3


func _ready():
	fov = CameraController.CAMERA_FOV
	position.z = CameraController.CAMERA_DISTANCE
	last_face = global_position.normalized()


func _move(axis: Vector3, immediate:= false):
	var parent = get_parent()
	last_face = global_position.normalized()
	if not axis.is_normalized():
		printerr("axis should be normalized !", axis)
		return
	_is_moving = true
	var pivot = Node3D.new()
	parent.add_child(pivot)
	Utils.switch_parent(self, pivot, true)
	var original_basis = pivot.basis
	var goal_basis = pivot.basis.rotated(axis, PI / 2)
	if immediate:
		pivot.basis = goal_basis
	else:
		var _tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		_tween.tween_method(func(t): pivot.basis = original_basis.slerp(goal_basis, t), 0., 1., DURATION)
		await _tween.finished
	Utils.switch_parent(self, parent, true)
	pivot.free()
	_is_moving = false
