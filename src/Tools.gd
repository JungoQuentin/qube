@tool
extends Node

@onready var player_preload = preload("res://src/player/player.tscn")
@onready var map_preload = preload("res://src/MapCube/MapCube.tscn")
@onready var env_preload = preload("res://src/EnvLightCam.tscn")

func _ready():
	print("tool ready")

func create_new_lvl(scene, lvl_name):
	var new_lvl = add_node3d(scene, lvl_name)
	_add_and_set_owner(env_preload.instantiate(), new_lvl)
	_add_and_set_owner(map_preload.instantiate(), new_lvl)
	_add_and_set_owner(player_preload.instantiate(), new_lvl)
	return new_lvl

func _add_and_set_owner(node, parent):
	parent.add_child(node)
	node.set_owner(get_tree().edited_scene_root)

func add_node3d(parent, new_name):
	var node3d = Node3D.new()
	parent.add_child(node3d)
	node3d.set_owner(get_tree().edited_scene_root)
	node3d.name = new_name
	return node3d