extends Cube
class_name MovingCube


@onready var _level = get_tree().current_scene
## if the cube as fall in a hole
var in_a_hole:= false


func _ready():
	_mesh = SphereMesh.new()
	_mesh_instance.mesh = _mesh
	_collision_shape.shape.size = Vector3.ONE * Colors.cube_scale
	_initial_color = Colors.get_initial_color(Cube.object_to_type(self))
	_touched_color = Colors.darker(_initial_color)
	_mesh_instance.set_surface_override_material(0, _mesh_instance.get_surface_override_material(0).duplicate(true))
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color


func on_push(direction: Vector3, floor_direction: Vector3):
	var floor_goal = _get_floor_goal(direction, floor_direction)
	var current_floor = _get_current_floor(floor_direction)
	var position_goal:= position + direction
	if floor_goal == null or floor_goal is HoleCube: # change face or hole
		position_goal += floor_direction
	if floor_goal is HoleCube:
		in_a_hole = true
		floor_goal.fill()
	
	var tween = create_tween()
	tween.tween_property(self, "position", position_goal, 0.02)
	await tween.finished
	
	var the_next = _get_floor_goal(direction, floor_direction)
	if the_next is MovingCube and the_next.can_push(floor_direction, -direction):
		the_next.on_push(floor_direction, -direction)
	elif floor_goal == null and current_floor is IceCube and can_push(floor_direction, -direction):
		on_push(floor_direction, -direction)
	elif floor_goal is IceCube:
		var neighbour = _get_neighbour(direction)
		if neighbour is MovingCube and neighbour.can_push(direction, floor_direction):
			neighbour.on_push(direction, floor_direction)
		elif can_push(direction, floor_direction):
			on_push(direction, floor_direction)


func _get_neighbour(direction: Vector3) -> Node3D:
	return Utils.get_raycast_collider(_level, self.global_position, direction)


func _get_floor_goal(direction: Vector3, floor_direction: Vector3):
	return Utils.get_raycast_collider(_level, self.global_position + direction, floor_direction)


func _get_current_floor(floor_direction: Vector3):
	return Utils.get_raycast_collider(_level, self.global_position, floor_direction)


func can_push(direction: Vector3, floor_direction: Vector3) -> bool:
	var floor_goal = _get_floor_goal(direction, floor_direction)
	if floor_goal != null and floor_goal.is_rejecting(): # TODO check
		return false
	if floor_goal is MovingCube and not floor_goal.in_a_hole:
		return false
	if _get_neighbour(direction) != null:
		return false
	return true
