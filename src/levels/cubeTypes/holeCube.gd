extends Cube 
class_name HoleCube

var filled:= false

func _ready():
	_mesh.size = Vector3.ONE * Colors.cube_scale
	_collision_shape.shape.size = _mesh.size
	_mesh_instance.set_surface_override_material(0, _mesh_instance.get_surface_override_material(0).duplicate(true))
	_mesh_instance.get_surface_override_material(0).albedo_color = Color.TRANSPARENT


func on_touch():
	pass


## If a cube is in, disable the collision
func fill():
	filled = true
	_collision_shape.disabled = true


func reset():
	filled = false
	_collision_shape.disabled = false
