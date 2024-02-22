extends Node

class Settings extends Savable:
	var save_file: int # 0, 1, 2
	var music_volume: int # 0 to 10
	var sound_volume: int # 0 to 10
	var locale: String # "fr", "en", ...
	var all_puzzle_unlocked: bool
	
	func _init(
		_save_file:= 0, 
		_music_volume:= 8,
		_sound_volume:= 8,
		_locale:= "fr",
		_all_puzzle_unlocked:= false
	):
		save_file = _save_file
		music_volume = _music_volume
		sound_volume = _sound_volume
		locale = _locale
		all_puzzle_unlocked = _all_puzzle_unlocked

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
