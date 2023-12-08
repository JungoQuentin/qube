extends Cube
class_name IceCube


## Return the position of the next "non-sliding" block
func get_end_slide(direction: Vector3, floor_direction: Vector3) -> Vector3:
	var next: Cube = Utils.get_raycast_collider(get_tree().current_scene, global_position, direction)
	if next is IceCube:
		return next.get_end_slide(direction, floor_direction)
	return next.global_position
