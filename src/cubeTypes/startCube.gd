extends Cube 

func _ready():
	Global.startCube = self
	super._ready()
	cube_type = START
	initial_color = Colors.start_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color