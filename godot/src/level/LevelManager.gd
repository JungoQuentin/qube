class_name LevelManager


static func win(tree: SceneTree):
	if not Save.progressions[Save.settings.save_file].completed_levels.has(tree.current_scene.scene_file_path):
		Save.progressions[Save.settings.save_file].completed_levels.push_front(tree.current_scene.scene_file_path)
		Save.save()
	LevelManagerRS.goto_level_gate(tree)


static func is_level_finished(pack: PackedScene) -> bool:
	return Save.progressions[Save.settings.save_file].completed_levels.has(pack.resource_path)


static func get_current_progression() -> Progression:
	return Save.progressions[Save.settings.save_file]
