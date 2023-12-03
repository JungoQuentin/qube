extends Cube
class_name MovingCube

#region DECLARATION

@onready var _level = get_tree().current_scene

var speed: float
var is_moving = false

#endregion


func _ready():
	super._ready()
	initial_color = Colors.moving_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color


func on_push(direction: Vector3, floor_direction: Vector3):
	var _is_going_to_change_face = true if _get_floor_goal(direction, floor_direction) == null else false
	if not _is_going_to_change_face:
		position += direction
	else:
		position += direction + floor_direction


func _get_neighbour(direction: Vector3, floor_direction: Vector3) -> Node3D:
	return Utils.get_raycast_collider(_level, self.global_position, direction)


func _get_floor_goal(direction: Vector3, floor_direction: Vector3):
	return Utils.get_raycast_collider(_level, self.global_position + direction, floor_direction)


func can_push(direction: Vector3, floor_direction: Vector3) -> bool:
	var floor_goal = _get_floor_goal(direction, floor_direction)
	var is_floor_rejecting = floor_goal != null and floor_goal.is_rejecting()
	var is_floor_a_moving_cube = floor_goal is MovingCube
	return not is_floor_rejecting and _get_neighbour(direction, floor_direction) == null and not is_floor_a_moving_cube
