@tool extends Node

@onready var player_preload = preload("res://src/player/player.tscn")
@onready var map_preload = preload("res://src/mapCube/MapCube.tscn")
@onready var env_preload = preload("res://src/env/EnvLightCam.tscn")
const TEMPLATES_PATH = "res://addons/lvldesigner/templates"
const LEVELS_PATH = "res://addons/lvldesigner/levels"
const LVL_DESIGNER_PATH = "res://addons/lvldesigner/scene/LevelDesignerScene.tscn"
const TEST_LVL_PATH = "res://addons/lvldesigner/levels/tmp_lvl.tscn"

var plugin: BCubePlugin

func create_new_lvl(scene, lvl_name, _test: bool=false) -> Node3D:
	var new_lvl = add_node3d(scene, scene, lvl_name if not _test else "TEST")
	add_and_set_own(env_preload.instantiate(), new_lvl, new_lvl)
	add_and_set_own(player_preload.instantiate(), new_lvl, new_lvl)
	add_and_set_own(map_preload.instantiate(), new_lvl, new_lvl)
	return new_lvl

func add_and_set_own(node, parent, _owner):
	parent.add_child(node)
	if _owner != null:
		node.set_owner(_owner)

func add_node3d(parent, _owner, new_name) -> Node3D:
	var node3d = Node3D.new()
	node3d.name = new_name
	add_and_set_own(node3d, parent, _owner)
	return node3d

func save_scene(new_lvl: Node3D, path: String):
	var scene = PackedScene.new()
	var result = scene.pack(new_lvl)
	if result != OK:
		Log.error("error", result, "append...")
		return
	var error = ResourceSaver.save(scene, path)
	if error != OK:
		Log.error("An error occurred while saving the scene to disk.")


func alert(msg: String, title: String="alert"):
	OS.alert(msg, title)