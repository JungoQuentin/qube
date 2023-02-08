extends Node

var player: Node3D = null
var map_cube: Node3D = null # TODO remane map_cube
var direction: Vector3
var startCube: StaticBody3D = null


func surface_touched_animation_start(_mesh_instance, tween, initial_color, touched_color, end_callback):
	var _tmp_mesh = _mesh_instance.mesh.duplicate(true)
	_mesh_instance.mesh = _tmp_mesh
	var _material = _tmp_mesh.surface_get_material(0)
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_material, "albedo_color", touched_color, 0.05)
	tween.tween_property(_material, "albedo_color", initial_color, 1)
	tween.tween_callback(end_callback)
	tween.play()
	# TODO add sound 
	# idee : une note jouee par un xylophone, chaque bloque a une note differente d'une gamme


func wait_player_end_rolling(incr=0.01, _timeout=10):
	var i = 0.0
	while Global.player.is_rolling and i < _timeout:
		i += incr
		await get_tree().create_timer(incr).timeout
