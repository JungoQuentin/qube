extends MoveLogic
class_name CubeMoveLogic

var _is_on_edge = false
## null if _is_on_edge
var floor_goal: Cube
var has_neighbour: bool
var neighbour: Node3D

## Init the logic for a cube rolling. Only for moving cubes and player
func init_forward_roll():
	self._pivot = Node3D.new()
	self._object.add_child(self._pivot)
	Utils.switch_parent(self._object.mesh_instance,self. _pivot)
	self._object.is_moving = true
	self.neighbour = Utils.get_raycast_collider(self._object, Vector3.ZERO, self._direction)
	self.has_neighbour = true if neighbour != null else false
	self._object.is_on_edge = not Utils.get_raycast_collider(self._object, self._direction, Vector3.DOWN)
	self.floor_goal = Utils.get_raycast_collider(self._object, self._direction, Vector3.DOWN)
	self._is_on_edge = not self.floor_goal
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
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_method(_tween_basis, 0., 0.1, _object.speed / 2) 
	tween.tween_method(_tween_basis, 0.1, 0., _object.speed / 2) 
	await tween.finished
	reset_pivot()

## Lauch the animation of a cube rolling. Only for moving cubes and player
func roll():
	_offset()
	var axis = _set_goals()
	_goal = _pivot.basis.rotated(axis, PI/2) if not _is_on_edge else _pivot.basis.rotated(-axis, PI)
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_method(_tween_basis, 0., 1., _object.speed if not _is_on_edge else _object.speed * 2) 
	await tween.finished
	return self

## Reset the pivot and rotator. Only for moving cubes and player
func reset_pivot():
	if not _object.is_moving: # modified elsewhere
		return
	_object.mesh_instance.position = Vector3.ZERO
	Utils.switch_parent(_object.mesh_instance, _object)
	_pivot.queue_free()

## Reset the cube position. Only for moving cubes and player
func reset_position(reset_direction: Vector3):
	if not _object.is_moving: # modified elsewhere
		return
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