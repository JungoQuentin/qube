@tool extends Node3D

@export var lauch: bool = false:
	set(_on): _lauch()

func _lauch():
	var parent = _add_node3d()
	# Normal cube
	for cell in $GridMap.get_used_cells_by_item(0):
		_add_cube(cell, parent, $LCube)

func _add_cube(new_position, parent, to_dup):
	var node = to_dup.duplicate()
	parent.add_child(node)
	node.position = new_position
	node.visible = true
	node.set_owner(get_tree().edited_scene_root)

func _add_node3d():
	var node3d = Node3D.new()
	add_child(node3d)
	node3d.set_owner(get_tree().edited_scene_root)
	return node3d