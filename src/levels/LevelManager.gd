extends Node

@export var levels: Array[PackedScene]
var current_level_index:= 0
var completed_levels: Array


func _ready():
	await Save.loaded
	if not Save.config.has_section("progression"):
		completed_levels = levels.map(func(l): return false)
		save()
	else:
		completed_levels = Save.config.get_value("progression", "completed_levels")
		current_level_index = Save.config.get_value("progression", "current_level_index")


func goto_level_gate():
	get_tree().change_scene_to_file("res://src/levels/000_entry_point.tscn")


func goto_next_level():
	goto_level_by_index(current_level_index + 1)


func goto_level_by_index(index: int):
	if levels.size() <= index:
		return
	get_tree().change_scene_to_packed(levels[index])
	current_level_index = index


func win():
	completed_levels[current_level_index] = true
	save()
	goto_level_gate()


func save():
	Save.config.set_value("progression", "completed_levels", completed_levels)
	Save.config.set_value("progression", "current_level_index", current_level_index)
	Save.save()
