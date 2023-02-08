@tool
extends Node3D

@export var lauch: bool = false:
	set(_on): _lauch()

@onready var NORMAL = preload("res://src/MapCube/cubeTypes/normalCube.tscn")
@onready var BLOCKING = preload("res://src/MapCube/cubeTypes/blockingCube.tscn")
@onready var START = preload("res://src/MapCube/cubeTypes/startCube.tscn")
@onready var END = preload("res://src/MapCube/cubeTypes/endCube.tscn")

var cube_preload: Dictionary
var n_start_cube = 0

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
	var parent = _add_node3d()
	_add_cubes_by_type(parent, cubeType.NORMAL)
	_add_cubes_by_type(parent, cubeType.BLOCKING)
	_add_cubes_by_type(parent, cubeType.START)
	_add_cubes_by_type(parent, cubeType.END)
	$GridMap.visible = false

func _add_cubes_by_type(parent, type):
	var cells = $GridMap.get_used_cells_by_item(type)
	if (type == cubeType.START or type == cubeType.END) and cells.size()> 1:
		print("TROP DE ", cubeType.keys()[type])
		parent.queue_free() # TODO BUG editor tool ?
		return
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