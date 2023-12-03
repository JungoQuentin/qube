extends Node
class_name CubeMoveLogic

#region DECLARATION

var _object: Node3D
var _direction: Vector3
var _floor_direction: Vector3
var _tween: Tween
var _goal: Basis
var _start: Basis
var _is_going_to_change_face: bool
@onready var _level = get_tree().current_scene
@onready var _pivot: Node3D = Node3D.new() # preload("res://src/dbg/DbgPivot.tscn").instantiate()
## null if _is_on_edge
var floor_goal: Cube
var floor_start: Cube
var has_neighbour: bool
var neighbour: Node3D

#endregion


## Init the shared logic for a cube rolling or a map rotation
func _init(object: Node3D, direction: Vector3, floor_direction: Vector3):
	_object = object
	_floor_direction = floor_direction
	_object.add_child(self)
	_direction = direction

## Init the logic for a cube rolling. Only for moving cubes and player
func init_forward_roll():
	_level.add_child(_pivot)
	_pivot.global_position = _object.global_position
	_pivot.position += _direction / 2 + _floor_direction / 2
	Utils.switch_parent(_object, _pivot, true)
	
	#TODO
	#neighbour = Utils.get_raycast_collider(_object, Vector3.ZERO, _direction)
	#has_neighbour = true if neighbour != null else false
	
	floor_start = Utils.get_raycast_collider(_level, _object.global_position, _floor_direction)
	floor_goal = Utils.get_raycast_collider(_level, _object.global_position + _direction, _floor_direction)
	_is_going_to_change_face = true if floor_goal == null else false
	if _is_going_to_change_face:
		floor_goal = floor_start
	return self

## Lauch the animation of a cube rolling. Only for moving cubes and player
func roll():
	var axis = _direction.cross(_floor_direction)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI / 2 if not _is_going_to_change_face else -PI)
	_tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	# TODO check si le if marche dans le cas ou j'annule (est-ce que ca kill le tween)
	_tween.tween_method(func(t): if _object.is_moving:_pivot.basis = _start.slerp(_goal, t), 0., 1., _object.speed if not _is_going_to_change_face else _object.speed * 2) 
	await _tween.finished
	floor_goal.on_touch()
	return self


func roll_back():
	_direction = -_direction
	var axis = _direction.cross(_floor_direction)
	_goal = _start
	_start = _pivot.basis
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	# TODO check si le if marche dans le cas ou j'annule (est-ce que ca kill le tween)
	_tween.tween_method(func(t): if _object.is_moving:_pivot.basis = _start.slerp(_goal, t), 0., 1., _object.speed)# if not _is_on_edge else _object.speed * 2) 
	await _tween.finished
	floor_start.on_touch()
	return self

## Reset the pivot and rotator. Only for moving cubes and player
# TODO rename remove
func reset_pivot():
	if not _object.is_moving: # modified elsewhere TODO
		return
	Utils.switch_parent(_object, _level, true)
	_pivot.queue_free()
