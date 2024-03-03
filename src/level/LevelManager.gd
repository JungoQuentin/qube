class_name LevelManager


static var entry_point: PackedScene = load("res://src/level/000_entry_point.tscn")
static var _current_level_pack: PackedScene


static func goto_level_gate(tree: SceneTree):
	tree.change_scene_to_packed(entry_point)


static func goto_level_by_packed(pack: PackedScene, tree: SceneTree):
	tree.change_scene_to_packed(pack)
	_current_level_pack = pack


static func win(tree: SceneTree):
	if OS.is_debug_build() and not _current_level_pack:
		goto_level_gate(tree)
		return
	if not Save.progressions[Save.settings.save_file].completed_levels.has(_current_level_pack.resource_path):
		Save.progressions[Save.settings.save_file].completed_levels.push_front(_current_level_pack.resource_path)
		Save.save()
	goto_level_gate(tree)


static func is_level_finished(pack: PackedScene) -> bool:
	return Save.progressions[Save.settings.save_file].completed_levels.has(pack.resource_path)


static func get_current_progression() -> Progression:
	return Save.progressions[Save.settings.save_file]
