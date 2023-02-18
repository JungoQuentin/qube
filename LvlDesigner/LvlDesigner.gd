@tool extends Node3D

var _lvl_path = ""
var _new_lvl = null
var _highest_cube: int = -10
var _grid_map: GridMap

var dimension = 0
@export var lvl_name = "":
	set(n_lvl_name):
		lvl_name = n_lvl_name
		_lvl_path = "res://LvlDesigner/new_levels/{}.tscn".format([lvl_name], "{}")

@onready var cube_preload: Dictionary = {
	cubeType.NORMAL : preload("res://src/cubeTypes/normalCube.tscn"),
	cubeType.BLOCKING : preload("res://src/cubeTypes/blockingCube.tscn"),
	cubeType.START : preload("res://src/cubeTypes/startCube.tscn"),
	cubeType.END : preload("res://src/cubeTypes/endCube.tscn"),
	cubeType.SINGLE_USE: preload("res://src/cubeTypes/singleUseCube.tscn"),
}

const TEST_LVL_PATH = "res://LvlDesigner/new_levels/tmp_test.tscn"

enum cubeType {
	NORMAL = 0,
	BLOCKING,
	START,
	END,
	SINGLE_USE,
}

################### EDITOR #####################

var _editor_interface: EditorInterface
var _selection: EditorSelection


func _ready():
	_selection = Tools.plugin.editor_interface.get_selection()
	_editor_interface = Tools.plugin.editor_interface
	Tools.plugin.lvl_editor_scene = self
	print("tool ready")

func add_template(_name):
	print("newmap ", _name)
	var path = "res://LvlDesigner/templates/{}".format([_name], "{}")
	if not FileAccess.file_exists(path):
		OS.alert("dont exist...")
		return
	var template = load(path).instantiate()
	Tools.add_and_set_own(template, self, get_tree().edited_scene_root)
	dimension = int(_name[0])

################# TEST #########################

func test(n_dimension):
	dimension = n_dimension
	if _set_gridmap() or not _ok(true):
		return
	_create_level(true)
	_new_lvl.queue_free()
	_editor_interface.reload_scene_from_path(TEST_LVL_PATH)
	_editor_interface.play_custom_scene(TEST_LVL_PATH)

################# LAUCH #########################

func save(n_dimension, n_lvl_name):
	dimension = n_dimension
	lvl_name = n_lvl_name
	if _set_gridmap() or not _ok():
		return
	_create_level()
	_reset()

################# CREATE LEVEL #########################

func _create_level(_test=false):
	_new_lvl = Tools.create_new_lvl(self, lvl_name, _test)
	var map_cube: MapCube = _new_lvl.find_child("MapCube", true, false)
	map_cube.dimension = dimension
	var cubes = Tools.add_node3d(map_cube, _new_lvl, "cubes")
	for type in cubeType.values():
		_add_cubes_by_type(_grid_map, cubes, type)
	if _grid_map.get_used_cells_by_item(cubeType.START)[0].y < _highest_cube:
		OS.alert("Le cube start n'est pas en haut !!")
		_reset()
		return
	Tools.save_scene(_new_lvl, _lvl_path if not _test else TEST_LVL_PATH)

################## CHECK ########################

func _ok(_test=false) -> bool:
	if not _test and FileAccess.file_exists(_lvl_path):
		OS.alert("Attention ! ce nom de niveau est deja prix !")
		return false
	if _check_one_type(_grid_map, cubeType.START):
		return false
	if _check_one_type(_grid_map, cubeType.END):
		return false
	return true 

func _check_one_type(gridmap, type) -> bool:
	var cells = gridmap.get_used_cells_by_item(type)
	if cells.size() != 1:
		OS.alert("Tu ne peut mettre qu'un seul start !".format([cubeType.keys()[type]], '{}'))
		return ERR_BUG
	return OK 

################## SET GRIDMAP ########################

func _set_gridmap() -> bool:
	for child in get_children():
		if child is GridMap:
			_grid_map = child
			return OK
	OS.alert("Le premier object de la liste en haut a gauche doit etre la gridmap !!")
	return ERR_BUG

##################### ADD CUBE #######################

func _add_cubes_by_type(gridmap, parent, type):
	var cells: Array[Vector3i] = gridmap.get_used_cells_by_item(type)
	for cell in cells:
		if cell.y > _highest_cube:
			_highest_cube = cell.y
		_add_cube(_grid_map.to_global(cell) + Vector3(0.5, 0.5, 0.5), parent, cube_preload[type], cubeType.keys()[type])

func _add_cube(new_position, parent, object, new_name):
	var node = object.instantiate()
	node.position = new_position
	node.visible = true
	node.name = new_name
	Tools.add_and_set_own(node, parent, _new_lvl)

####################### RESET #########################

func _reset():
	_new_lvl.queue_free()
	_new_lvl = null
	_highest_cube = -10


