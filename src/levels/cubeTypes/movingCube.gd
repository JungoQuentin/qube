extends Cube
class_name MovingCube

#region DECLARATION

@onready var _level = get_tree().current_scene
## if the cube as fall in a hole
var in_a_hole:= false

#endregion


func on_push(direction: Vector3, floor_direction: Vector3):
	var floor_goal = _get_floor_goal(direction, floor_direction)
	if floor_goal == null or floor_goal is HoleCube: # change face or hole
		position += direction + floor_direction
	else:
		position += direction
	if floor_goal is HoleCube:
		in_a_hole = true
		floor_goal.fill()


func _get_neighbour(direction: Vector3) -> Node3D:
	return Utils.get_raycast_collider(_level, self.global_position, direction)


func _get_floor_goal(direction: Vector3, floor_direction: Vector3):
	return Utils.get_raycast_collider(_level, self.global_position + direction, floor_direction)


func can_push(direction: Vector3, floor_direction: Vector3) -> bool:
	var floor_goal = _get_floor_goal(direction, floor_direction)
	var is_floor_rejecting = floor_goal != null and floor_goal.is_rejecting()
	var is_floor_a_moving_cube = floor_goal is MovingCube and not floor_goal.in_a_hole
	return not is_floor_rejecting and \
		_get_neighbour(direction) == null and \
		not is_floor_a_moving_cube
