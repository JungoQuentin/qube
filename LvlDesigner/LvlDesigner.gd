@tool extends Node3D

@export var lauch: bool = false:
	set(_on): _lauch()

var cube_preload: Dictionary

enum cubeType {
	NORMAL,
	BLOCKING,
	START,
	END,
}

func _ready():
	cube_preload = {
		cubeType.NORMAL : preload("res://src/MapCube/cubeTypes/normalCube.tscn"),
		cubeType.BLOCKING : preload("res://src/MapCube/cubeTypes/blockingCube.tscn"),
		cubeType.START : preload("res://src/MapCube/cubeTypes/startCube.tscn"),
		cubeType.END : preload("res://src/MapCube/cubeTypes/endCube.tscn"),
	}

func _lauch():
	var current_gridmap: GridMap = get_child(0)
	var parent = _add_node3d()
	_add_cubes_by_type(current_gridmap, parent, cubeType.NORMAL)
	_add_cubes_by_type(current_gridmap, parent, cubeType.BLOCKING)
	_add_cubes_by_type(current_gridmap, parent, cubeType.START)
	_add_cubes_by_type(current_gridmap, parent, cubeType.END)
	current_gridmap.visible = false

func _check_n_start_end(cells, type) -> bool:
	if (type == cubeType.START or type == cubeType.END) and cells.size() > 1:
		print("TROP DE ", cubeType.keys()[type])
		return true
	if (type == cubeType.START or type == cubeType.END) and cells.size() == 0:
		print("PAS ASSEZ DE ", cubeType.keys()[type])
		return true
	return false

func _add_cubes_by_type(gridmap, parent, type):
	var cells = gridmap.get_used_cells_by_item(type)
	if _check_n_start_end(cells, type):
		parent.queue_free() # TODO BUG editor tool ?
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