extends MovingCube 
class_name SnowBallCube


func _ready():
	_mesh = SphereMesh.new()
	_mesh_instance.mesh = _mesh
	_collision_shape.shape.size = Vector3.ONE * _color_set.cube_scale
	_initial_color = _color_set.get_initial_color(Cube.object_to_type(self))
	_touched_color = ColorSet.darker(_initial_color)
	_mesh_instance.set_surface_override_material(0, _mesh_instance.get_surface_override_material(0).duplicate(true))
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color
