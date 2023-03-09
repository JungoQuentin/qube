extends Cube 
class_name StartCube

func _ready():
	get_tree().current_scene.startCube = self
	super._ready()
	initial_color = Colors.start_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color