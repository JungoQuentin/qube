extends Cube

func _ready():
	super._ready()
	cube_type = BLOCKING
	initial_color = Global.blocking_init_color
	touched_color = Global.blocking_touched_color
	mesh.surface_get_material(0).albedo_color = initial_color

func on_touch():
	super.on_touch()
	await Utils.wait_while(func(): return Global.player.is_rolling)
	Actions.actions.pop_back()
	Global.player.roll(-Global.direction, false)