extends Node

@export_range(0, 1) var cube_scale = 0.95

@export_category("Colors")
@export_subgroup("NormalCube")
@export var normal_init_color = Color.REBECCA_PURPLE
@export var normal_touched_color = Color.WHITE
@export_subgroup("BlockingCube")
@export var blocking_init_color = Color.DARK_GRAY
@export var blocking_touched_color = Color.BLACK
@export_subgroup("SingleCube")
@export var single_cube_init_color = Color.DARK_GRAY
@export var single_cube_touched_color = Color.BLACK

var player: Node3D = null
var map_cube: MapCube = null # TODO remane map_cube
var direction: Vector3
var startCube: Cube = null

func wait_player_end_rolling(incr=0.01, _timeout=10):
	var i = 0.0
	while Global.player.is_rolling and i < _timeout:
		i += incr
		await get_tree().create_timer(incr).timeout