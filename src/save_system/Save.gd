extends Node

const SAVE_PATH = &"res://save.cfg"
const SETTINGS_SECTION_NAME = &"settings"
#const SAVE_PATH = &"user://save.cfg"
var config = ConfigFile.new()
var settings: Settings
signal loaded


func _ready():
	if not FileAccess.file_exists(SAVE_PATH):
		save()
	if config.load(SAVE_PATH) != OK:
		Utils.crash("problem loading the config file !")
		return
	settings = Settings.load_from_config_or_default(config, SETTINGS_SECTION_NAME, Settings.new())
	save()
	TranslationServer.set_locale(settings.locale)
	loaded.emit()


func save():
	settings.save_to_config(config, SETTINGS_SECTION_NAME)
	for i in range(LevelManager.progressions.size()):
		LevelManager.progressions[i].save_to_config(config, LevelManager.get_progression_section_name(i))
	config.save(SAVE_PATH)
