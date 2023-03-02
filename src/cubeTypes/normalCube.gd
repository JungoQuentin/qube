extends Cube
class_name NormalCube

func _ready():
	super._ready()
	initial_color = Colors.normal_init_color
	touched_color = Colors.darker(Colors.normal_init_color)
	mesh.surface_get_material(0).albedo_color = initial_color
