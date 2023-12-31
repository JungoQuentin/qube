extends Node
class_name CubeMoveLogic


enum {
	SQUISH,
	MOVE # pivot rotation animation
}
const MOVE_ANIMATION = &"move_animation"

var _object: Node3D
var _direction: Vector3
var _floor_direction: Vector3
var _tween: Tween
var _goal: Basis
var _start: Basis
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
@onready var _animation: Animation = _animation_library.get_animation(MOVE_ANIMATION)


## Init the shared logic for a cube rolling or a map rotation
func _init(object: Node3D, direction: Vector3, floor_direction: Vector3):
	_object = object
	_floor_direction = floor_direction
	_object.add_child(self)
	_direction = direction
	add_child(_animation_player)
	_animation_player.add_animation_library("", _animation_library)

## Init the logic for a cube rolling. Only for moving cubes and player
func init_forward_roll():
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
	return self

## Lauch the animation of a cube rolling. Only for moving cubes and player
func roll():
	var axis = _direction.cross(_floor_direction)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI / 2 if not _is_going_to_change_face else -PI)
	
	_animation.track_set_path(SQUISH, get_path_to(_object) as String + ":scale:y")
	_animation.track_set_path(MOVE, get_path_to(_pivot) as String + ":scale:x")
	_animation_player.play(MOVE_ANIMATION)
	
	await _animation_player.animation_finished

	_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	# TODO check si le if marche dans le cas ou j'annule (est-ce que ca kill le tween)
	# -> quand j'abort pendant, il faudrai plutot kill le tween en sois...
	_tween.tween_method(func(t): if _object.is_moving:_pivot.basis = _start.slerp(_goal, t), 0., 1., _object.speed if not _is_going_to_change_face else _object.speed * 2) 
	await _tween.finished
	if is_going_to_slide and _is_going_to_change_face:
		await _new_roll()
	elif is_going_to_slide:
		await _slide()
	return self


func roll_back():
	_direction = -_direction
	var axis = _direction.cross(_floor_direction)
	_goal = _start
	_start = _pivot.basis
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	# TODO check si le if marche dans le cas ou j'annule (est-ce que ca kill le tween)
	# -> quand j'abort pendant, il faudrai plutot kill le tween en sois...	
	_tween.tween_method(func(t): if _object.is_moving:_pivot.basis = _start.slerp(_goal, t), 0., 1., _object.speed)# if not _is_on_edge else _object.speed * 2) 
	await _tween.finished
	floor_start.on_touch()
	return self

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
	_level.add_child(_pivot)
	_pivot.global_position = _object.global_position
	_pivot.position += _direction / 2 + _floor_direction / 2
	Utils.switch_parent(_object, _pivot, true)


func _new_roll():
	var new_move_logic = CubeMoveLogic.new(_object, _floor_direction, -_direction).init_forward_roll()
	_object.move_logic = new_move_logic
	await new_move_logic.roll()
	floor_goal = new_move_logic.floor_goal


func _slide():
	var start_position = _object.global_position
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
