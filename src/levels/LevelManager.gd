extends Node

@export var levels: Array[PackedScene]
var current_level_index:= 0


func goto_level_gate():
	get_tree().change_scene_to_file("res://src/levels/000_entry_point.tscn")


func goto_next_level():
	goto_level_by_index(current_level_index + 1)


func goto_level_by_index(index: int):
	if levels.size() <= index:
		return
	get_tree().change_scene_to_packed(levels[index])
	current_level_index = index
