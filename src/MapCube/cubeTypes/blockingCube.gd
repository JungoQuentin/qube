extends Cube

func _ready():
	super._ready()
	touched_color = Color.BLACK

func on_touch():
	super.on_touch()
	await Global.wait_player_end_rolling()
	Global.player.roll(-Global.direction)