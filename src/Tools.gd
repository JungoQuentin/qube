@tool
extends Node

@onready var player_preload = preload("res://src/player/player.tscn")
@onready var map_preload = preload("res://src/MapCube/MapCube.tscn")
@onready var env_preload = preload("res://src/EnvLightCam.tscn")

func _ready():
	print("tool ready")

func create_new_lvl(scene, lvl_name) -> Node3D:
	var new_lvl = add_node3d(scene, lvl_name)
	add_and_set_own(env_preload.instantiate(), new_lvl)
	add_and_set_own(map_preload.instantiate(), new_lvl)
	add_and_set_own(player_preload.instantiate(), new_lvl)
	return new_lvl

func add_and_set_own(node, parent):
	if parent == null and node == null:
		print("node and parent are null")
	if parent == null:
		Log.info("parent is null, child is: ", node.name)
	if node == null:
		Log.info("node is null, parent is: ", parent.name)
	if parent == null or node == null:
		return
	parent.add_child(node)
	#node.set_owner(parent)
	#node.set_owner(get_tree().edited_scene_root)

func parent_is_owner(node):
	for child in node.get_children():
		print(child.name)
		child.set_owner(node)
		parent_is_owner(child)

func add_node3d(parent, new_name) -> Node3D:
	var node3d = Node3D.new()
	node3d.name = new_name
	add_and_set_own(node3d, parent)
	return node3d