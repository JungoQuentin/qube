@tool extends Node3D

@export var lauch: bool = false:
	set(_on): _lauch()
@export var dimension = 0
@export var lvl_name = ""

@onready var lvl_preload = preload("res://templates/level_x.tscn")


enum cubeType {
	NORMAL,
	BLOCKING,
	START,
	END,
}

var cube_preload: Dictionary
func _ready():
	cube_preload = {
		cubeType.NORMAL : preload("res://src/MapCube/cubeTypes/normalCube.tscn"),
		cubeType.BLOCKING : preload("res://src/MapCube/cubeTypes/blockingCube.tscn"),
		cubeType.START : preload("res://src/MapCube/cubeTypes/startCube.tscn"),
		cubeType.END : preload("res://src/MapCube/cubeTypes/endCube.tscn"),
	}

func _lauch():
	if not _args_valid(): return
	var current_gridmap: GridMap = get_child(0)
	var parent = _add_node3d()
	if _add_cubes_by_type(current_gridmap, parent, cubeType.START): return
	if _add_cubes_by_type(current_gridmap, parent, cubeType.END): return
	if _add_cubes_by_type(current_gridmap, parent, cubeType.NORMAL): return
	if _add_cubes_by_type(current_gridmap, parent, cubeType.BLOCKING): return
	#current_gridmap.visible = false

	var new_lvl = _add_lvl()
	var map_cube = new_lvl.find_child("MapCube")
	map_cube.add_child(parent)
	# mettre parent dans MapCube
	# Run le niveau

	_reset()

func _add_lvl():
	# TODO rename node3d
	var node3d = lvl_preload.instantiate()
	add_child(node3d)
	node3d.set_owner(get_tree().edited_scene_root)
	node3d.name = lvl_name
	return node3d


func _args_valid() -> bool:
	if dimension == 0 or dimension % 2 == 0 or dimension < 3:
		OS.alert("mauvaise dimension (0 ou pair, doit commencer a 3)")
		return false
	if lvl_name.length() == 0:
		OS.alert("faut donner un nom au niveau...")
		return false
	return true

func _add_cubes_by_type(gridmap, parent, type) -> bool:
	var cells = gridmap.get_used_cells_by_item(type)
	if _check_n_start_end(cells, type):
		parent.queue_free()
		return true
	for cell in cells:
		_add_cube(cell, parent, cube_preload[type], cubeType.keys()[type])
	return false

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
	
func _check_n_start_end(cells, type) -> bool:
	if (type == cubeType.START or type == cubeType.END) and cells.size() > 1:
		OS.alert("Apparement tu aurais mis trop de {}. Etais-ce volontaire ?".format([cubeType.keys()[type].to_lower()],'{}') , "TROP DE {}".format([cubeType.keys()[type]], '{}'))
		return true
	if (type == cubeType.START or type == cubeType.END) and cells.size() == 0:
		OS.alert("PAS ASSEZ DE {}".format([cubeType.keys()[type]], '{}'))
		return true
	return false

func _reset():
	dimension = 0
	lvl_name = ""