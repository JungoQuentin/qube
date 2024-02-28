extends Node

## Number of progession slots
const N_PROGRESSION = 3

@export var entry_point: PackedScene
var progressions: Array[Progression] = []
var _current_level_pack: PackedScene


func _ready():
	await Save.loaded
	for i in range(N_PROGRESSION):
		var progression = Progression.load_from_config_or_default(Save.config, get_progression_section_name(i), Progression.new())
		progressions.push_back(progression)
	Save.save()


func get_progression_section_name(index: int) -> String:
	return "progression_" + str(index)


func goto_level_gate():
	get_tree().change_scene_to_packed(entry_point)


func goto_level_by_packed(pack: PackedScene):
	get_tree().change_scene_to_packed(pack)
	_current_level_pack = pack


func win():
	if not progressions[Save.settings.save_file].completed_levels.has(_current_level_pack.resource_path):
		progressions[Save.settings.save_file].completed_levels.push_front(_current_level_pack.resource_path)
		Save.save()
	goto_level_gate()


func is_level_finished(pack: PackedScene) -> bool:
	return progressions[Save.settings.save_file].completed_levels.has(pack.resource_path)


func get_current_progression() -> Progression:
	return progressions[Save.settings.save_file]
