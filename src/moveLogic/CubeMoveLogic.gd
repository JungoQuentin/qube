extends Node
class_name CubeMoveLogic

#region DECLARATION

var _object: Node3D
var _direction: Vector3
var _pivot: Node3D
var _start: Basis
var _goal: Basis
var _tween: Tween
var _level
var _is_on_edge = false
## null if _is_on_edge
var floor_goal: Cube
var has_neighbour: bool
var neighbour: Node3D

#endregion


## Init the shared logic for a cube rolling or a map rotation
func _init(object: Node3D, direction: Vector3):
	_object = object
	_object.add_child(self)
	_direction = direction
	_level = _object.get_tree().current_scene


func _set_goals():
	var axis = _direction.cross(Vector3.DOWN)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(-axis, PI / 2)
	return axis


func _tween_basis(t):
	if _object.is_moving:
		_pivot.basis = _start.slerp(_goal, t)


## Init the logic for a cube rolling. Only for moving cubes and player
func init_forward_roll():
	_pivot = Node3D.new()
	_object.add_child(_pivot)
	Utils.switch_parent(_object.mesh_instance, _pivot)
	_object.is_moving = true
	neighbour = Utils.get_raycast_collider(_object, Vector3.ZERO, _direction)
	has_neighbour = true if neighbour != null else false
	_object.is_on_edge = not Utils.get_raycast_collider(_object, _direction, Vector3.DOWN)
	floor_goal = Utils.get_raycast_collider(_object, _direction, Vector3.DOWN)
	_is_on_edge = not floor_goal
	return self

## Lauch the animation of the player pushing (moving a bit) his neighbour). Only for player
func push_neighbour():
	var neighbour_block = Utils.get_raycast_collider(_object, Vector3.ZERO, _direction)
	if neighbour_block == null:
		return
	if not neighbour_block is MovingCube:
		Log.crash("comment un block voisin peut etre autre chose qu'un moving cube ??")
	neighbour_block.on_push(_direction)
	_offset()
	var axis = _direction.cross(Vector3.DOWN)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI/2) if not _is_on_edge else _pivot.basis.rotated(-axis, PI)
	_tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	_tween.tween_method(_tween_basis, 0., 0.1, _object.speed / 2) 
	_tween.tween_method(_tween_basis, 0.1, 0., _object.speed / 2) 
	await _tween.finished
	reset_pivot()

## Lauch the animation of a cube rolling. Only for moving cubes and player
func roll():
	_offset()
	var axis = _set_goals()
	_goal = _pivot.basis.rotated(axis, PI/2) if not _is_on_edge else _pivot.basis.rotated(-axis, PI)
	_tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	_tween.tween_method(_tween_basis, 0., 1., _object.speed if not _is_on_edge else _object.speed * 2) 
	await _tween.finished
	return self

## Reset the pivot and rotator. Only for moving cubes and player
func reset_pivot():
	if not _object.is_moving: # modified elsewhere
		return
	_object.mesh_instance.position = Vector3.ZERO
	Utils.switch_parent(_object.mesh_instance, _object)
	_pivot.queue_free()
	_object.is_moving = false

## Reset the cube position. Only for moving cubes and player
func reset_position(reset_direction: Vector3):
	if not has_neighbour:
		_object.position += reset_direction 
	await get_tree().physics_frame
	var block = Utils.get_raycast_collider(_object, Vector3.ZERO, Vector3.DOWN)
	if block:
		block.on_touch(_direction, _object)
	return block

func _offset():
	_pivot.position += _direction / 2 + Vector3.DOWN / 2
	_object.mesh_instance.position -= _direction / 2 + Vector3.DOWN / 2