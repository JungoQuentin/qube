@tool extends Node3D

var is_running = false

@export var dimension = 3
@export var lvl_name = "test1"
@export var lauch: bool = false:
	set(_on): 
		if not is_running:
			is_running = true
			_lauch()
			is_running = false

@onready var lvl_preload: PackedScene = preload("res://templates/level_x.tscn")
@onready var cube_preload: Dictionary = {
	cubeType.NORMAL : preload("res://src/MapCube/cubeTypes/normalCube.tscn"),
	cubeType.BLOCKING : preload("res://src/MapCube/cubeTypes/blockingCube.tscn"),
	cubeType.START : preload("res://src/MapCube/cubeTypes/startCube.tscn"),
	cubeType.END : preload("res://src/MapCube/cubeTypes/endCube.tscn"),
}

enum cubeType {
	NORMAL = 0,
	BLOCKING,
	START,
	END,
}

func _lauch():
	if _check():
		return

	var new_lvl = Tools.create_new_lvl(self, lvl_name)
	var map_cube = new_lvl.find_child("MapCube", true, false)
	if map_cube == null:
		Log.error("map cube is null!")
		return

	var cubes = Tools.add_node3d(map_cube, "cubes")
	var current_gridmap: GridMap = get_child(0)
	for type in cubeType.values():
		_add_cubes_by_type(current_gridmap, cubes, type)
	

	_save_scene(new_lvl)
	new_lvl.queue_free()
	_reset()

#### CHECK ####
func _check() -> bool:
	# TODO check file name 
	if not _args_valid():
		return true
	var current_gridmap: GridMap = get_child(0)
	# TODO is a gridmap ?
	if _check_n_start_end(current_gridmap):
		return true
	return false

func _args_valid() -> bool:
	if dimension == 0 or dimension % 2 == 0 or dimension < 3:
		OS.alert("mauvaise dimension (0 ou pair, doit commencer a 3)")
		print("end alert")
		return false
	if lvl_name.length() == 0:
		OS.alert("faut donner un nom au niveau...")
		return false
	return true

func _check_n_start_end(gridmap, type=cubeType.START) -> bool:
	# TODO simplify
	var cells = gridmap.get_used_cells_by_item(type)
	if (type == cubeType.START or type == cubeType.END) and cells.size() > 1:
		OS.alert("Apparement tu aurais mis trop de {}. Etais-ce volontaire ?".format([cubeType.keys()[type].to_lower()],'{}') , "TROP DE {}".format([cubeType.keys()[type]], '{}'))
		return true
	if (type == cubeType.START or type == cubeType.END) and cells.size() == 0:
		OS.alert("PAS ASSEZ DE {}".format([cubeType.keys()[type]], '{}'))
		return true
	if type == cubeType.START:
		return _check_n_start_end(gridmap, cubeType.END)
	else:
		return false

#### ADD CUBE ####

func _add_cubes_by_type(gridmap, parent, type):
	var cells = gridmap.get_used_cells_by_item(type)
	for cell in cells:
		_add_cube(cell, parent, cube_preload[type], cubeType.keys()[type])

func _add_cube(new_position, parent, object, new_name):
	var node = object.instantiate()
	node.position = new_position
	node.visible = true
	node.name = new_name
	Tools.add_and_set_own(node, parent)

#### SAVE ####

func _save_scene(new_lvl: Node3D):
	var scene = PackedScene.new()
	Tools.parent_is_owner(new_lvl)
	var result = scene.pack(new_lvl)
	if result != OK:
		print(result)
		return
	var path = "res://src/levels/{}.tscn".format([lvl_name], "{}")
	var error = ResourceSaver.save(scene, path)
	if error != OK:
		push_error("An error occurred while saving the scene to disk.")
	
#### RESET ####

func _reset():
	#dimension = 0
	#lvl_name = ""
	is_running = false