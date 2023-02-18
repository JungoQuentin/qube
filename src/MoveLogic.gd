extends Node
class_name MoveLogic

var _rotator: Node3D
var _rotator_start: Basis 
var _rotator_goal: Basis

var _object: Node3D
var _direction: Vector3
var _pivot: Node3D
var _start: Basis
var _goal: Basis
var _is_on_edge = false
var has_neighbour: bool
var neighbour: Node3D

func _init(object: Node3D, direction: Vector3):
	_object = object
	_object.add_child(self)
	_direction = direction
	_rotator = Node3D.new()

func init_map_rotation():
	_object.get_parent().add_child(_rotator)
	_pivot = _object
	_object.is_moving = true
	return self

func init_forward_roll():
	self._pivot = Node3D.new()
	self._object.add_child(self._pivot)
	Utils.switch_parent(self._object.mesh_instance,self. _pivot)
	self._object.is_moving = true
	self.neighbour = Utils.get_raycast_collider(self._object, Vector3.ZERO, self._direction)
	self.has_neighbour = true if neighbour != null else false
	self._object.is_on_edge = not Utils.get_raycast_collider(self._object, self._direction, Vector3.DOWN)
	self._is_on_edge = not Utils.get_raycast_collider(self._object, self._direction, Vector3.DOWN)
	return self

###########

func push_neighbour(): # Only for player
	var neighbour_block = Utils.get_raycast_collider(_object, Vector3.ZERO, _direction)
	if neighbour_block == null:
		return
	if neighbour_block.cube_type != Cube.MOVING:
		Log.crash("comment un block voisin peut etre autre chose qu'un moving cube ??")
	neighbour_block.on_push(_direction)
	offset()
	var axis = _direction.cross(Vector3.DOWN)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI/2) if not _is_on_edge else _pivot.basis.rotated(-axis, PI)
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_method(_tween_basis, 0., 0.1, _object.speed / 2) 
	tween.tween_method(_tween_basis, 0.1, 0., _object.speed / 2) 
	await tween.finished
	reset_pivot()

func _set_goals():
	var axis = _direction.cross(Vector3.DOWN)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(-axis, PI / 2)
	_rotator_start = _rotator.basis
	_rotator_goal = _rotator.basis.rotated(-axis, PI / 2)
	return axis

func roll():
	var axis = _set_goals()
	_goal = _pivot.basis.rotated(axis, PI/2) if not _is_on_edge else _pivot.basis.rotated(-axis, PI)
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_method(_tween_basis, 0., 1., _object.speed if not _is_on_edge else _object.speed * 2) 
	await tween.finished
	return self

func map_rotate():
	_set_goals()
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_method(_tween_basis, 0., 1., Global.player.speed * 2)
	await tween.finished
	return self


func offset():
	_pivot.position += _direction / 2 + Vector3.DOWN / 2
	_object.mesh_instance.position -= _direction / 2 + Vector3.DOWN / 2
	return self

func _tween_basis(t):
	if not _object.is_moving:
		return
	_pivot.basis = _start.slerp(_goal, t)
	_rotator.basis = _rotator_start.slerp(_rotator_goal, t)

func reset_pivot():
	if not _object.is_moving : # modified elsewhere
		return
	_object.mesh_instance.position = Vector3.ZERO
	Utils.switch_parent(_object.mesh_instance, _object)
	_pivot.queue_free()
	_rotator.queue_free()

func reset_position(reset_direction: Vector3):
	if not _object.is_moving : # modified elsewhere
		return
	if not has_neighbour:
		_object.position += reset_direction 
	await get_tree().physics_frame
	var block = Utils.get_raycast_collider(_object, Vector3.ZERO, Vector3.DOWN)
	if block:
		block.on_touch(_direction, _object)
	return block
