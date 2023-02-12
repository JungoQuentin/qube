extends Node

@export_range(0, 1) var cube_scale = 0.965

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
@export_subgroup("StartCube")
@export var start_cube_init_color = Color.DARK_GRAY
@export var start_cube_touched_color = Color.BLACK
@export_subgroup("EndCube")
@export var end_cube_init_color = Color.DARK_GRAY
@export var end_cube_touched_color = Color.BLACK
@export_subgroup("SwitchCube")
@export var switch_cube_on_color = Color.YELLOW
@export var switch_cube_off_color = Color.BLACK

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

func wait_while(condition: Callable, timeout=5, frequency=0.01) -> bool:
	var passed = 0.0
	while condition.call():
		if passed > timeout: return false
		passed += frequency
		await get_tree().create_timer(frequency).timeout
	return true

func _init_level():
	print("init level")
	await wait_while(func(): print(map_cube);return map_cube == null, 1)
	print("map cube exist")
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
