extends Node
class_name MoveLogic

var _object: Node3D
var _direction: Vector3
var _pivot: Node3D

var _start: Basis
var _goal: Basis


func _init(object: Node3D):
	_object = object
	object.add_child(self)

	_pivot = Node3D.new()
	_object.add_child(_pivot)
	Utils.switch_parent(_object.mesh_instance, _pivot)


func roll(direction: Vector3):
	_direction = direction
	_object.is_moving = true
	_object.is_pushing = Utils.push_neighbour(_object, direction)
	Global.direction = direction
	_object.is_on_edge = not Utils.get_raycast_collider(_object, _direction, Vector3.DOWN)
	_offset()
	await _animation()
	if not _object.is_moving : # modified elsewhere
		return
	if not _object.is_on_edge:
		reset_pivot(_direction)
	if _object.is_on_edge:
		var shift = Global.map_cube.dimension - 1
		reset_pivot(-shift * _direction)


func _offset():
	_pivot.position += _direction / 2 + Vector3.DOWN / 2
	_object.mesh_instance.position -= _direction / 2 + Vector3.DOWN / 2

func _animation():
	var axis = _direction.cross(Vector3.DOWN)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI/2) if not _object.is_on_edge else _pivot.basis.rotated(-axis, PI)

	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	if _object.is_pushing:
		tween.tween_method(_tween_basis, 0., 0.1, _object.speed / 2) 
		tween.tween_method(_tween_basis, 0.1, 0., _object.speed / 2) 
	else:
		tween.tween_method(_tween_basis, 0., 1., _object.speed if not _object.is_on_edge else _object.speed * 2) 
	await tween.finished

func _tween_basis(t):
	if not _object.is_moving:
		return
	_pivot.basis = _start.slerp(_goal, t)

signal end_reset

func reset_pivot(reset_direction: Vector3):
	_object.is_moving= false
	_object.mesh_instance.position = Vector3.ZERO
	Utils.switch_parent(_object.mesh_instance, _object)
	_pivot.queue_free()
	if not _object.is_pushing:
		_object.position += reset_direction 
	await get_tree().physics_frame
	var block = Utils.get_raycast_collider(_object, Vector3.ZERO, Vector3.DOWN)
	if block:
		block.on_touch()
	end_reset.emit()
