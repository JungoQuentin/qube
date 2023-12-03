extends Cube
class_name BlockingCube

func _ready():
	super._ready()
	initial_color = Colors.blocking_init_color # TODO static function in Colors.get_color_by_cube(self)
	touched_color = Colors.darker(initial_color) 
	mesh.surface_get_material(0).albedo_color = initial_color
