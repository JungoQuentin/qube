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
var _pivot: Node3D
var is_going_to_hole:= false
var floor_goal: Cube
var floor_start: Cube
var is_going_to_slide:= false
## is only used for movingCubes in the edge
var floor_neighbour: Cube

#endregion


## Init the shared logic for a cube rolling or a map rotation
func _init(object: Node3D, direction: Vector3, floor_direction: Vector3):
	_object = object
	_floor_direction = floor_direction
	_object.add_child(self)
	_direction = direction
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


## Lauch the animation of a cube rolling. Only for moving cubes and player
func roll():
	var axis = _direction.cross(_floor_direction)
	_start = _pivot.basis
	_goal = _pivot.basis.rotated(axis, PI / 2 if not _is_going_to_change_face else -PI)
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(func(t): _pivot.basis = _start.slerp(_goal, t), 0., 1., _object.speed if not _is_going_to_change_face else _object.speed * 2) 
	await _tween.finished
	if is_going_to_slide and _is_going_to_change_face:
		await _new_roll()
	elif is_going_to_slide:
		await _slide()
	return self

## Reset the pivot and rotator. Only for moving cubes and player
func remove_pivot():
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
	var new_move_logic = CubeMoveLogic.new(_object, _floor_direction, -_direction)
	_object.move_logic = new_move_logic
	await new_move_logic.roll()
	floor_goal = new_move_logic.floor_goal


func _slide():
	var is_going_to_change_face_by_slide = floor_goal.will_change_face(_direction, _floor_direction)
	var goal_position = floor_goal.get_end_slide(_direction, _floor_direction) - _floor_direction
	if is_going_to_change_face_by_slide:
		goal_position = floor_goal.get_end_slide(_direction, _floor_direction) + _direction - _floor_direction
		await _level.camera_controller.player_change_face(_direction, _floor_direction)
	remove_pivot()

	_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_object, "global_position", goal_position, _object.speed)
	await _tween.finished
	
	var neighbour = Utils.get_raycast_collider(_level, _object.global_position, _direction)
	if neighbour is MovingCube and neighbour.can_push(_direction, _floor_direction):
		await neighbour.on_push(_direction, _floor_direction)
		
	floor_goal = _get_floor_under_object()
	if is_going_to_change_face_by_slide:
		await _new_roll()
	_transfert_in_pivot()


func abort():
	if _tween:
		_tween.stop()
		_tween.kill()
	if _pivot:
		remove_pivot()


func can_roll() -> bool:
	if floor_goal and floor_goal.is_rejecting():
		return false
	if is_going_to_hole:
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
	await Utils.sleep(0.01)
