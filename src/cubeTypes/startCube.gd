extends Cube 

func _ready():
	Global.startCube = self
	super._ready()
	cube_type = START
	initial_color = Global.start_cube_init_color
	touched_color = Global.start_cube_touched_color
	mesh.surface_get_material(0).albedo_color = initial_color