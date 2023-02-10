extends Node

var player: Node3D = null
var map_cube: MapCube = null # TODO remane map_cube
var direction: Vector3
var startCube: Cube = null

func wait_player_end_rolling(incr=0.01, _timeout=10):
	var i = 0.0
	while Global.player.is_rolling and i < _timeout:
		i += incr
		await get_tree().create_timer(incr).timeout