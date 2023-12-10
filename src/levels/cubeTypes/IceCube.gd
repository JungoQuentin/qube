extends Cube
class_name IceCube

@onready var _level = get_tree().current_scene


## Return the position of the next "non-sliding" block
func get_end_slide(direction: Vector3, floor_direction: Vector3) -> Vector3:
	var neighbour: Cube = Utils.get_raycast_collider(_level, global_position - floor_direction, direction)
	if neighbour:
		return global_position
	var floor_goal = Utils.get_raycast_collider(_level, global_position + direction - floor_direction, floor_direction)
	if floor_goal is MovingCube:
		return global_position
	var next: Cube = Utils.get_raycast_collider(_level, global_position, direction)
	if next == null: # on edge
		# TODO dirty calcul
		return self.get_end_slide(floor_direction, -direction)
	if next is HoleCube:
		return global_position
	if next is IceCube:
		return next.get_end_slide(direction, floor_direction)
	return next.global_position

## Check if we will slide to another face
func will_change_face(direction: Vector3, floor_direction: Vector3) -> bool:
	var neighbour: Cube = Utils.get_raycast_collider(_level, global_position - floor_direction, direction)
	if neighbour:
		return false
	var next: Cube = Utils.get_raycast_collider(_level, global_position, direction)
	if next == null: # on edge
		return true
	if next is HoleCube:
		return false
	if next is IceCube:
		return next.will_change_face(direction, floor_direction)
	return false
