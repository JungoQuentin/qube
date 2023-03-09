extends Node
class_name MoveLogic

var _object: Node3D
var _direction: Vector3
var _pivot: Node3D
var _start: Basis
var _goal: Basis
var _tween: Tween
var _level

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
