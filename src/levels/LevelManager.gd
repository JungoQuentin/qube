extends Node

@export var entry_point: PackedScene
var completed_levels: Array#[String]
var _current_level_pack: PackedScene


func _ready():
	await Save.loaded
	if not Save.config.has_section("progression"):
		completed_levels = []
		save()
	else:
		completed_levels = Save.config.get_value("progression", "completed_levels")


func goto_level_gate():
	get_tree().change_scene_to_packed(entry_point)


func goto_level_by_packed(pack: PackedScene):
	get_tree().change_scene_to_packed(pack)
	_current_level_pack = pack


func win():
	if not completed_levels.has(_current_level_pack.resource_path):
		completed_levels.push_front(_current_level_pack.resource_path)
	save()
	goto_level_gate()


func save():
	Save.config.set_value("progression", "completed_levels", completed_levels)
	Save.save()


func is_level_finished(pack: PackedScene) -> bool:
	return completed_levels.has(pack.resource_path)
