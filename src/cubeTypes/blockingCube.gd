extends Cube
class_name BlockingCube

func _ready():
	super._ready()
	initial_color = Colors.blocking_init_color
	touched_color = Colors.darker(initial_color) 
	mesh.surface_get_material(0).albedo_color = initial_color

func on_touch(direction: Vector3, cube):
	super.on_touch(direction, cube)
	await _send_cube_back(direction, cube)
