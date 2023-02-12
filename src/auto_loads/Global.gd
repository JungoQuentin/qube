extends Node

var player: Node3D = null
var map_cube: MapCube = null
var direction: Vector3
var startCube: Cube = null
enum { INGAME, PAUSE, MENU }
var game_state = INGAME

var switch_cubes: Array
var single_use_cubes: Array

func _ready():
	for child in get_children():
		child.queue_free()

	await _init_level()

func _init_level():
	await Utils.wait_while(func(): return map_cube == null, 1)
	var map_cube_children = map_cube.get_child(0).get_children()
	switch_cubes = map_cube_children.filter(func(cube): return cube.cube_type == Cube.SWITCH)
	single_use_cubes = map_cube_children.filter(func(cube): return cube.cube_type == Cube.SINGLE_USE)

func check_all_switch_state():
	if switch_cubes.all(func(cube): return cube.on):
		print("ALL TRUE !")
		# TODO

func quit_level():
	player = null
	map_cube = null
	startCube = null
	switch_cubes.clear()
	single_use_cubes.clear()