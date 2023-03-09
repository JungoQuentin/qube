extends MoveLogic
class_name MapMoveLogic

var _rotator: Node3D
var _rotator_start: Basis 
var _rotator_goal: Basis

func _init(object: Node3D, direction: Vector3):
	super._init(object, direction)
	_rotator = Node3D.new()

## Init the logic for a map rotation. Only for map
func init_map_rotation():
	_object.get_parent().add_child(_rotator)
	_pivot = _object
	_object.is_moving = true
	Utils.switch_parent(_level.player, _rotator)
	_level.moving_cubes.map(func(cube): Utils.switch_parent(cube, _rotator, true))
	return self

## Lauch the animation of the map rotating. Only for map
func map_rotate():
	_set_goals()
	_tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	_tween.tween_method(_tween_basis, 0., 1., _level.player.speed * 2)
	await _tween.finished
	return self

### OVERRIDES ###

func _tween_basis(t):
	if _object.is_moving:
		super._tween_basis(t)
		_rotator.basis = _rotator_start.slerp(_rotator_goal, t)

func _set_goals():
	var axis = super._set_goals()
	_rotator_start = _rotator.basis
	_rotator_goal = _rotator.basis.rotated(-axis, PI / 2)
	return axis
