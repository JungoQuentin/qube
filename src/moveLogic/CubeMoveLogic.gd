extends Node
class_name CubeMoveLogic


enum {
	SQUISH,
	MOVE # pivot rotation animation
}
const MOVE_ANIMATION = &"normal_roll_animation"
const CHANGE_FACE_ROLL_ANIMATION = &"change_face_roll_animation"

var _object: Node3D
var _direction: Vector3
var _floor_direction: Vector3
var _tween: Tween
var _is_going_to_change_face: bool
@onready var _level = get_tree().current_scene
var _pivot: Node3D
var is_going_to_hole:= false
var floor_goal: Cube
var floor_start: Cube
var is_going_to_slide:= false
## is only used for movingCubes in the edge
var floor_neighbour: Cube
var _animation_player:= AnimationPlayer.new()
@onready var _animation_library: AnimationLibrary = preload("res://src/moveLogic/move_animation_library.tres")



## Init the shared logic for a cube rolling or a map rotation
func _init(object: Node3D, direction: Vector3, floor_direction: Vector3):
	_object = object
	_floor_direction = floor_direction
	_object.add_child(self)
	_direction = direction
	add_child(_animation_player)
	_animation_player.add_animation_library("", _animation_library)
	_animation_player.root_node = get_path_to(get_parent())

	_transfert_in_pivot()
	floor_start = _get_floor_under_object()
	floor_goal = Utils.get_raycast_collider(_level, _object.global_position + _direction, _floor_direction)
	
	## are we going to change face ?
	## if the floor_goal is a MovingCube that can be pushed, then yes
	if floor_goal != null and floor_goal is MovingCube and not floor_goal.in_a_hole:
		_is_going_to_change_face = floor_goal.can_push(_floor_direction, -_direction)
		floor_neighbour = floor_goal
	else:
		_is_going_to_change_face = true if floor_goal == null else false
		is_going_to_hole = floor_goal is HoleCube
	if _is_going_to_change_face:
		floor_goal = floor_start
	if floor_goal is IceCube:
		is_going_to_slide = true


func direction_to_axis(direction) -> int: # Vector3.AXIS_{X, Y, Z}
	return abs(_object.basis.inverse() * direction).max_axis_index()

## Lauch the animation of a cube rolling. Only for moving cubes and player
func roll():
	if _is_going_to_change_face:
		await change_face_roll()
	else:
		await normal_roll()


func change_face_roll():
	pass


func normal_roll():
	var squish_axis_str = Utils.vector_axis_to_str(direction_to_axis(_floor_direction))
	var normal_roll_animation = _animation_library.get_animation(MOVE_ANIMATION)
	var squish_path = get_path_to(_object) as String + ":scale:" + squish_axis_str
	print(squish_path)
	normal_roll_animation.track_set_path(SQUISH, squish_path)
	
	var axis = _direction.cross(_floor_direction)
	var rotation_axis_str = Utils.vector_axis_to_str(abs(axis).max_axis_index())
	var rotation_axis_sign = axis[abs(axis).max_axis_index()]
	normal_roll_animation.track_set_key_value(MOVE, 1, normal_roll_animation.track_get_key_value(MOVE, 1).map(func(f): return f * rotation_axis_sign))
	var rotation_path = get_path_to(_pivot) as String + ":rotation:" + rotation_axis_str
	print(rotation_path)
	normal_roll_animation.track_set_path(MOVE, rotation_path)
	
	
	_animation_player.play(MOVE_ANIMATION)
	
	await _animation_player.animation_finished
	normal_roll_animation.track_set_key_value(MOVE, 1, normal_roll_animation.track_get_key_value(MOVE, 1).map(func(f): return f * rotation_axis_sign))


## Reset the pivot and rotator. Only for moving cubes and player
# TODO rename remove
func remove_pivot():
	if not _object.is_moving: # modified elsewhere TODO
		return
	Utils.switch_parent(_object, _level, true)
	_pivot.queue_free()


func _get_floor_under_object() -> Cube:
	return Utils.get_raycast_collider(_level, _object.global_position, _floor_direction)


func _transfert_in_pivot():
	_pivot = Node3D.new()
	_pivot.name = _object.name + "_pivot"
	_level.add_child(_pivot)
	_pivot.global_position = _object.global_position
	_pivot.position += _direction / 2 + _floor_direction / 2
	Utils.switch_parent(_object, _pivot, true)


func _new_roll():
	var new_move_logic = CubeMoveLogic.new(_object, _floor_direction, -_direction)
	_object.move_logic = new_move_logic
	await new_move_logic.roll()
	floor_goal = new_move_logic.floor_goal


func _slide():
	var is_going_to_change_face_by_slide = floor_goal.will_change_face(_direction, _floor_direction)
	var goal_position = floor_goal.get_end_slide(_direction, _floor_direction) - _floor_direction
	if is_going_to_change_face_by_slide:
		goal_position = floor_goal.get_end_slide(_direction, _floor_direction) + _direction - _floor_direction
		await _level.camera.player_move(_direction, _floor_direction)
	remove_pivot()

	_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_object, "global_position", goal_position, _object.speed)
	await _tween.finished
	floor_goal = _get_floor_under_object()
	if is_going_to_change_face_by_slide:
		await _new_roll()
	_transfert_in_pivot()


func abort():
	_tween.stop()
	_tween.kill()
	if not _pivot == null:
		remove_pivot()


func can_roll() -> bool:
	if floor_goal and floor_goal.is_rejecting():
		return false
	if is_going_to_hole:
		return false
	if floor_goal is LivingCube:
		return false
	if floor_goal is BlockingCube:
		return false
	if floor_neighbour is MovingCube and not floor_neighbour.in_a_hole and not floor_neighbour.can_push(_floor_direction, -_direction):
		return false
	## if our neighbour is a MovingCube, we try to push him
	var neighbour: Cube = Utils.get_raycast_collider(_level, _object.global_position, _direction)
	if neighbour is MovingCube and not neighbour.can_push(_direction, _floor_direction):
		return false
	return true


func cant_roll():
	print("cant roll anim !")
	await Utils.sleep(0.5)
