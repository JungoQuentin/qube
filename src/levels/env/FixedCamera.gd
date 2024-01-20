class_name FixedCamera extends Camera3D

@onready var _level: Level = get_tree().current_scene
var _is_moving = false
var last_face: Vector3
const DURATION = 0.3


func _ready():
	fov = Level.CAMERA_FOV
	position.z = Level.CAMERA_DISTANCE
	last_face = global_position.normalized()


func is_front_player() -> bool:
	return global_position.normalized().is_equal_approx(_level.object_current_face(_level.player))


func go_to_player():
	match _level.camera_mode:
		Level.CameraMode.FIXED:
			if not is_front_player():
				var player_face = _level.object_current_face(_level.player)
				if Vector3.ZERO.is_equal_approx(global_position.normalized().cross(player_face)):
					await _move(global_position.normalized().cross(last_face))
				await _move(global_position.normalized().cross(player_face))
		Level.CameraMode.NATURAL:
			if not _level.style_camera.current:
				_level.style_camera.transform = transform
				_level.style_camera.make_current()
			
			if not is_front_player():
				var player_face = _level.object_current_face(_level.player)
				if Vector3.ZERO.is_equal_approx(global_position.normalized().cross(player_face)):
					await _move(global_position.normalized().cross(last_face), true)
					_is_moving = true
					await _level.style_camera.transition_to(self)
					_is_moving = false
				await _move(global_position.normalized().cross(player_face), true)
			
			_is_moving = true
			await _level.style_camera.transition_back()
			_is_moving = false


func player_move(direction: Vector3, floor_direction):
	await _move(direction.cross(floor_direction))


func handle_input(input: String):
	if ["rotate_left", "rotate_right"].has(input):
		var axis = basis * {
			"rotate_left": Vector3.FORWARD,
			"rotate_right": Vector3.BACK,
		}[input]
		await _move(axis)
	else: 
		var axis = basis * {
			"camera_bottom": Vector3.RIGHT,
			"camera_right": Vector3.UP,
			"camera_left": Vector3.DOWN,
			"camera_top": Vector3.LEFT,
		}[input]
		var immediate = not current
		await _move(axis, immediate)
		
		if not current:
			_is_moving = true
			await _level.style_camera.transition_to(self)
			_is_moving = false
			make_current()


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
