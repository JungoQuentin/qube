extends Cube

@onready var blockingCubePreload = preload("res://src/MapCube/cubeTypes/blockingCube.tscn")
var is_used = false

func _ready():
	super._ready()
	touched_color = Color.BURLYWOOD

func on_leave():
	super.on_leave()
	initial_color = BLOCKING_INIT_COLOR
	touched_color = BLOCKING_TOUCHED_COLOR
	mesh.surface_get_material(0).albedo_color = initial_color
	is_used = true

func on_touch():
	super.on_touch()
	if is_used:
		super.on_touch()
		await Global.wait_player_end_rolling()
		Global.player.roll(-Global.direction)