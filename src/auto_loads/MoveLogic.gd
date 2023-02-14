extends Node

var _object: Node3D
var _direction: Vector3
var _pivot: Node3D

var _start: Basis
var _goal: Basis

func roll(object: Node3D, direction: Vector3, do_add_action=true):
	if object.is_moving or Global.map_cube.is_rotating:
		return
	_object = object
	_direction = direction
	object.is_moving = true
	object.is_pushing = Utils.push_neighbour(object, direction)
	Global.direction = direction
	_check_edge()
	_offset()
	_animation()

	if do_add_action:
		Actions.add_action(object.position, Global.map_cube.basis)
		Actions.undo_stack.clear()


func _check_edge():
	var collider = Utils.get_raycast_collider(self, _direction, Vector3.DOWN)
	_object.is_on_edge = !collider
	if _object.is_on_edge:
		Global.map_cube.start_cube_rotation(_direction)

func _offset():
	_pivot.position += _direction / 2 + Vector3.DOWN / 2
	_object.mesh_instance.position -= _direction / 2 + Vector3.DOWN / 2

func _animation():
	var axis = _direction.cross(Vector3.DOWN)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI/2) if not _object.is_on_edge else _pivot.basis.rotated(-axis, PI)

	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT_IN)
	if _object.is_pushing:
		tween.tween_method(_tween_basis, 0., 0.1, _object.speed / 2) 
		tween.tween_method(_tween_basis, 0.1, 0., _object.speed / 2) 
	else:
		tween.tween_method(_tween_basis, 0., 1., _object.speed if not _object.is_on_edge else _object.speed * 2) 
	await tween.finished
	if not _object.is_moving : # modified elsewhere
		return
	if not _object.is_on_edge:
		reset_pivot(_direction)
	if _object.is_on_edge:
		var shift = Global.map_cube.dimension - 1
		reset_pivot(-shift * _direction)

func _tween_basis(t):
	if not _object.is_rolling:
		return
	_pivot.basis = _start.slerp(_goal, t)

func reset_pivot(reset_direction: Vector3):
	_object.is_rolling = false
	_object.mesh_instance.position = Vector3.ZERO
	_pivot.transform = Transform3D.IDENTITY
	if not _object.is_pushing:
		_object.position += reset_direction 

	var block = Utils.get_raycast_collider(self, Vector3.ZERO, Vector3.DOWN)
	# TODO
	#if we_are_on_this_cube_now != null and we_are_on_this_cube_now != block:
	#	we_are_on_this_cube_now.on_leave()
	#we_are_on_this_cube_now = block
	if block:
		block.on_touch()