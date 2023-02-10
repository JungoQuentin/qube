extends Cube

func _ready():
	super._ready()
	BLOCKING_TOUCHED_COLOR = initial_color
	BLOCKING_INIT_COLOR = touched_color

func on_touch():
	super.on_touch()
	await Global.wait_player_end_rolling()
	Global.player.roll(-Global.direction)