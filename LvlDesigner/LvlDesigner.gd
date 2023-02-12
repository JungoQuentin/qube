@tool extends Node3D

var _lvl_path = ""
var _new_lvl = null
var _highest_cube: int = -10
var _grid_map: GridMap

@export var dimension = 0
@export var lvl_name = "":
	set(n_lvl_name):
		lvl_name = n_lvl_name
		_lvl_path = "res://LvlDesigner/new_levels/{}.tscn".format([lvl_name], "{}")

@onready var cube_preload: Dictionary = {
	cubeType.NORMAL : preload("res://src/cubeTypes/normalCube.tscn"),
	cubeType.BLOCKING : preload("res://src/cubeTypes/blockingCube.tscn"),
	cubeType.START : preload("res://src/cubeTypes/startCube.tscn"),
	cubeType.END : preload("res://src/cubeTypes/endCube.tscn"),
	cubeType.ONE : preload("res://src/cubeTypes/singleUseCube.tscn"),
}

enum cubeType {
	NORMAL = 0,
	BLOCKING,
	START,
	END,
	ONE,
}

################### EDITOR #####################

var _editor_plugin: EditorPlugin = EditorPlugin.new()
var _editor_interface: EditorInterface = _editor_plugin.get_editor_interface()
var _selection: EditorSelection = _editor_interface.get_selection()

func _ready():
	print("tool ready")
	_selection.selection_changed.connect(_on_selection_changed)

func _on_selection_changed():
	var selected = _selection.get_selected_nodes()
	if selected.size() != 1:
		return
	match selected[0].name:
		"CREATE":
			_lauch()
			_selection.remove_node(selected[0])
			_selection.add_node(self)
		"RELOAD":
			print("reload")
			_editor_interface.reload_scene_from_path("res://LvlDesigner/LevelDesigner.tscn")
			return
		"3x3", "5x5", "7x7":
			_add_template(selected[0])

func _add_template(node):
	var _name: String = node.name
	print("newmap ", _name)
	var path = "res://LvlDesigner/templates/{}.tscn".format([_name], "{}")
	if not FileAccess.file_exists(path):
		OS.alert("dont exist...")
		return
	var template = load(path).instantiate()
	Tools.add_and_set_own(template, self, get_tree().edited_scene_root)
	dimension = int(_name[0])
	_selection.remove_node(node)
	_selection.add_node(template)

################# LAUCH #########################

func _lauch():
	if _set_gridmap():
		return
	if not _ok():
		return

	_new_lvl = Tools.create_new_lvl(self, lvl_name)
	var map_cube: MapCube = _new_lvl.find_child("MapCube", true, false)
	map_cube.dimension = dimension
	var cubes = Tools.add_node3d(map_cube, _new_lvl, "cubes")
	for type in cubeType.values():
		_add_cubes_by_type(_grid_map, cubes, type)
	if _grid_map.get_used_cells_by_item(cubeType.START)[0].y < _highest_cube:
		OS.alert("Le cube start n'est pas en haut !!")
		_reset()
		return
	Tools.save_scene(_new_lvl, _lvl_path)
	_editor_interface.open_scene_from_path(_lvl_path)
	_reset()
	_editor_interface.play_current_scene()

################## CHECK ########################

func _ok() -> bool:
	if FileAccess.file_exists(_lvl_path):
		OS.alert("Attention ! ce nom de niveau est deja prix !")
		return false
	if not _args_valid():
		return false 
	if _check_one_type(_grid_map, cubeType.START):
		return false
	if _check_one_type(_grid_map, cubeType.END):
		return false
	return true 

func _args_valid() -> bool:
	if dimension == 0 or dimension % 2 == 0 or dimension < 3:
		OS.alert("mauvaise dimension (0 ou pair, doit commencer a 3)")
		print("end alert")
		return false
	if lvl_name.length() == 0:
		OS.alert("faut donner un nom au niveau...")
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
	dimension = 0
	lvl_name = ''
	_highest_cube = -10


