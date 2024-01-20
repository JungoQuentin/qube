extends Cube 
class_name HoleCube

var filled:= false

## If a cube is in, disable the collision
func fill():
	filled = true
	_collision_shape.disabled = true
	_mesh_instance.get_surface_override_material(0).albedo_color = Color.TRANSPARENT


func reset():
	filled = false
	_collision_shape.disabled = false
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color
