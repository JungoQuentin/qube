extends Node
class_name CameraController

static var CAMERA_DISTANCE = 18.5
static var CAMERA_FOV = 30.
static var RECORD_FOV_DEZOOM = 5.

enum ViewState { PLAYER, RECORD }
enum CameraMode { NATURAL, FIXED }

@onready var _record_effect: Control = preload("res://src/menu/RecordEffect.tscn").instantiate()
var _view_state: ViewState:
	set(new_state):
		_record_effect.visible = new_state == ViewState.RECORD
		_view_state = new_state
var _level: Level
var _camera_mode: CameraController.CameraMode
var _fixed_camera:= FixedCamera.new()
var _style_camera: Camera3D = _fixed_camera

var sub_viewport_container = SubViewportContainer.new()
var sub_viewport = SubViewport.new()

func _init(level: Level, camera_mode: CameraController.CameraMode):
	_level = level
	_camera_mode = camera_mode


func _ready():
	_init_camera()
	_level.add_child(_record_effect)
	_view_state = ViewState.PLAYER


func _init_camera():
	## init cameras
	#_level.add_child(sub_viewport_container)
	#sub_viewport_container.add_child(sub_viewport)
	#sub_viewport.add_child(_fixed_camera)
	_level.add_child(_fixed_camera)
	match _camera_mode:
		CameraMode.FIXED:
			_fixed_camera.make_current()
		CameraMode.NATURAL:
			_style_camera = NaturalCamera.new()
			add_child(_style_camera)
			_style_camera.make_current()


func get_camera_basis() -> Basis:
	return _fixed_camera.global_basis

## TODO quand le joueur change de face
func player_move(direction: Vector3, floor_direction):
	var immediate = _camera_mode == CameraMode.NATURAL
	immediate = false
	await _fixed_camera._move(direction.cross(floor_direction), immediate)

## Switch the effect to ViewState.PLAYER 
func _record_to_player():
	print("record to player")
	_view_state = ViewState.PLAYER
	_fixed_camera.fov = CAMERA_FOV
	_style_camera.fov = CAMERA_FOV

## Switch the effect to ViewState.RECORD 
func _player_to_record():
	print("player to record")
	_view_state = ViewState.RECORD
	_fixed_camera.fov = CAMERA_FOV + RECORD_FOV_DEZOOM
	_style_camera.fov = CAMERA_FOV + RECORD_FOV_DEZOOM

## To be called after undo / redo / reset
func after_meta():
	if _view_state == ViewState.RECORD:
		Utils.crash(["NOT implemented"])
		return
	var player_face = _level.object_current_face(_level.player)
	if _is_front_face(player_face):
		return
	await _camera_to_player_face()


func player_want_to_move():
	var player_face = _level.object_current_face(_level.player)
	if not _is_front_face(player_face):
		await _camera_to_player_face()
	await _record_to_player()


func _go_to_player():
	var player_face = _level.object_current_face(_level.player)
	if _view_state == ViewState.PLAYER:
		return
	_view_state = ViewState.PLAYER
	await _camera_to_player_face()

## Turn the camera face to the player
func _camera_to_player_face():
	var player_face = _level.object_current_face(_level.player)
	if _is_front_face(player_face):
		Utils.crash(["Logic error: already front the player"])
		return
	match _camera_mode:
		CameraMode.FIXED:
			if Vector3.ZERO.is_equal_approx(_fixed_camera.global_position.normalized().cross(player_face)):
				await _fixed_camera._move(_fixed_camera.global_position.normalized().cross(_fixed_camera.last_face))
			await _fixed_camera._move(_fixed_camera.global_position.normalized().cross(player_face))
		CameraMode.NATURAL:
			if not _style_camera.current:
				_style_camera.transform = _fixed_camera.transform
				_style_camera.make_current()
			
			if Vector3.ZERO.is_equal_approx(_fixed_camera.global_position.normalized().cross(player_face)):
				await _fixed_camera._move(_fixed_camera.global_position.normalized().cross(_fixed_camera.last_face), true)
				_fixed_camera._is_moving = true
				await _style_camera.transition_to(_fixed_camera)
				_fixed_camera._is_moving = false
			await _fixed_camera._move(_fixed_camera.global_position.normalized().cross(player_face), true)
			
			_fixed_camera._is_moving = true
			await _style_camera.transition_back()
			_fixed_camera._is_moving = false


func handle_input(input: String):
	if ["rotate_left", "rotate_right"].has(input):
		var axis = get_camera_basis() * {
			"rotate_left": Vector3.FORWARD,
			"rotate_right": Vector3.BACK,
		}[input]
		# TODO _move ?
		await _fixed_camera._move(axis)
	else:
		if _view_state == ViewState.PLAYER:
			await _player_to_record()
		else:
			print("stay in record")
		var axis = get_camera_basis() * {
			"camera_bottom": Vector3.RIGHT,
			"camera_right": Vector3.UP,
			"camera_left": Vector3.DOWN,
			"camera_top": Vector3.LEFT,
		}[input]
		var immediate = not _fixed_camera.current
		await _fixed_camera._move(axis, immediate)
		
		# TODO when the natural camera is current
		if not _fixed_camera.current:
			_fixed_camera._is_moving = true
			await _style_camera.transition_to(_fixed_camera)
			_fixed_camera._is_moving = false
			_fixed_camera.make_current()


func _is_front_face(face: Vector3) -> bool:
	return _fixed_camera.global_position.normalized().is_equal_approx(face)


func is_in_player_mode() -> bool:
	return _view_state == ViewState.PLAYER
