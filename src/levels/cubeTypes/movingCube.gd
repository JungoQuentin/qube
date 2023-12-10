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
	var current_floor = Utils.get_raycast_collider(_level, self.global_position, floor_direction)
	if current_floor is IceCube:
		return false
	var floor_goal = _get_floor_goal(direction, floor_direction)
	if floor_goal != null and floor_goal.is_rejecting(): # TODO check
		return false
	if floor_goal is MovingCube and not floor_goal.in_a_hole:
		return false
	if _get_neighbour(direction) != null:
		return false
	return true
