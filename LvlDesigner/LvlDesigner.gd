@tool extends Node3D

@export var lauch: bool = false:
	set(_on): _lauch()
@export var dimension = 0
@export var lvl_name = ""

@onready var lvl_preload: PackedScene = preload("res://templates/level_x.tscn")
@onready var cube_preload: Dictionary = {
	cubeType.NORMAL : preload("res://src/MapCube/cubeTypes/normalCube.tscn"),
	cubeType.BLOCKING : preload("res://src/MapCube/cubeTypes/blockingCube.tscn"),
	cubeType.START : preload("res://src/MapCube/cubeTypes/startCube.tscn"),
	cubeType.END : preload("res://src/MapCube/cubeTypes/endCube.tscn"),
}

enum cubeType {
	NORMAL,
	BLOCKING,
	START,
	END,
}



func _lauch():
	var vnew_lvl = _add_lvl()
	return
	if not _args_valid():
		return
	var current_gridmap: GridMap = get_child(0)
	if _check_n_start_end(current_gridmap):
		return
	var cubes = _add_node3d()
	_add_cubes_by_type(current_gridmap, cubes, cubeType.START)
	_add_cubes_by_type(current_gridmap, cubes, cubeType.END)
	_add_cubes_by_type(current_gridmap, cubes, cubeType.NORMAL)
	_add_cubes_by_type(current_gridmap, cubes, cubeType.BLOCKING)
	var new_lvl = _add_lvl()
	var map_cube = new_lvl.find_child("MapCube")
	remove_child(cubes)
	map_cube.add_child(cubes)
	cubes.set_owner(map_cube)
	#_reset()

func _add_lvl():
	var new_lvl = lvl_preload.instantiate(PackedScene.GEN_EDIT_STATE_MAIN_INHERITED)
	add_child(new_lvl)
	new_lvl.name = lvl_name
	new_lvl.set_owner(get_tree().edited_scene_root)
	return new_lvl


func _args_valid() -> bool:
	if dimension == 0 or dimension % 2 == 0 or dimension < 3:
		OS.alert("mauvaise dimension (0 ou pair, doit commencer a 3)")
		return false
	if lvl_name.length() == 0:
		OS.alert("faut donner un nom au niveau...")
		return false
	return true

func _add_cubes_by_type(gridmap, parent, type):
	var cells = gridmap.get_used_cells_by_item(type)
	for cell in cells:
		_add_cube(cell, parent, cube_preload[type], cubeType.keys()[type])

func _add_cube(new_position, parent, object, new_name):
	var node = object.instantiate()
	parent.add_child(node)
	node.position = new_position
	node.visible = true
	node.name = new_name
	node.set_owner(get_tree().edited_scene_root)

func _add_node3d():
	var node3d = Node3D.new()
	add_child(node3d)
	node3d.set_owner(get_tree().edited_scene_root)
	node3d.name = "map"
	return node3d
	
func _check_n_start_end(gridmap, type=cubeType.START) -> bool:
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

func _reset():
	dimension = 0
	lvl_name = ""