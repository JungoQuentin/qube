extends Cube

func _ready():
	super._ready()
	initial_color = Global.blocking_init_color
	touched_color = Global.blocking_touched_color
	mesh.surface_get_material(0).albedo_color = initial_color

func on_touch():
	super.on_touch()
	await Global.wait_player_end_rolling()
	Global.player.roll(-Global.direction)