extends Node
class_name MoveLogic

var _object: Node3D
var _direction: Vector3
var _pivot: Node3D
var _start: Basis
var _goal: Basis
signal end_reset

static func new_roll(object: Node3D, direction: Vector3):
	var new_self = MoveLogic.new()
	new_self._object = object
	object.add_child(new_self)
	new_self._pivot = Node3D.new()
	new_self._object.add_child(new_self._pivot)
	Utils.switch_parent(new_self._object.mesh_instance,new_self. _pivot)
	new_self._direction = direction
	new_self._object.is_moving = true
	new_self._object.has_neighbour = true if Utils.get_raycast_collider(new_self._object, Vector3.ZERO, new_self._direction) != null else false
	Global.direction = direction
	new_self._object.is_on_edge = not Utils.get_raycast_collider(new_self._object, new_self._direction, Vector3.DOWN)
	return new_self

func push_neighbour(): # Only for player
	var neighbour_block = Utils.get_raycast_collider(_object, Vector3.ZERO, _direction)
	if neighbour_block == null:
		return
	if neighbour_block.cube_type != Cube.MOVING:
		Log.crash("comment un block voisin peut etre autre chose qu'un moving cube ??")
	neighbour_block.on_push(_direction)
	_offset()
	var axis = _direction.cross(Vector3.DOWN)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI/2) if not _object.is_on_edge else _pivot.basis.rotated(-axis, PI)
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_method(_tween_basis, 0., 0.1, _object.speed / 2) 
	tween.tween_method(_tween_basis, 0.1, 0., _object.speed / 2) 
	await tween.finished
	reset_pivot()
	_object.is_moving = false

func roll():
	_offset()
	var axis = _direction.cross(Vector3.DOWN)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI/2) if not _object.is_on_edge else _pivot.basis.rotated(-axis, PI)
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_method(_tween_basis, 0., 1., _object.speed if not _object.is_on_edge else _object.speed * 2) 
	await tween.finished
	#reset_pivot()
	#if not _object.is_on_edge:
	#	reset_position(_direction)
	#if _object.is_on_edge:
	#	var shift = Global.map_cube.dimension - 1
	#	reset_position(-shift * _direction)
	#_object.is_moving = false

func _offset():
	_pivot.position += _direction / 2 + Vector3.DOWN / 2
	_object.mesh_instance.position -= _direction / 2 + Vector3.DOWN / 2

func _tween_basis(t):
	if not _object.is_moving:
		return
	_pivot.basis = _start.slerp(_goal, t)

func reset_pivot():
	if not _object.is_moving : # modified elsewhere
		return
	_object.mesh_instance.position = Vector3.ZERO
	Utils.switch_parent(_object.mesh_instance, _object)
	_pivot.queue_free()

func reset_position(reset_direction: Vector3):
	if not _object.is_moving : # modified elsewhere
		return
	if not _object.has_neighbour:
		_object.position += reset_direction 
	await get_tree().physics_frame
	var block = Utils.get_raycast_collider(_object, Vector3.ZERO, Vector3.DOWN)
	if block:
		block.on_touch()
	end_reset.emit()
