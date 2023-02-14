extends Cube

func _ready():
	super._ready()
	cube_type = BLOCKING
	initial_color = Colors.blocking_init_color
	touched_color = Colors.darker(initial_color) 
	mesh.surface_get_material(0).albedo_color = initial_color

func on_touch():
	super.on_touch()
	await Utils.wait_while(func(): return Global.player.is_moving)
	Actions.actions.pop_back()
	Global.player.roll(-Global.direction, false)