class_name Save

const SAVE_PATH = &"res://save.cfg"
const SETTINGS_SECTION_NAME = &"settings"
## Number of progession slots
const N_PROGRESSION = 3
#const SAVE_PATH = &"user://save.cfg"
static var config = ConfigFile.new()
static var settings: Settings
static var progressions: Array[Progression] = []
static var available_languages = Array(TranslationServer.get_loaded_locales())
## When the screen changes size, we need to update the 3D
## viewport quality setting. If we don't do this, the viewport will take
## the size from the main viewport.
static var viewport_start_size := Vector2(
	ProjectSettings.get_setting(&"display/window/size/viewport_width"),
	ProjectSettings.get_setting(&"display/window/size/viewport_height")
)

static func _static_init():
	## Init save file
	if not FileAccess.file_exists(SAVE_PATH):
		settings = Settings.new()
		save()
	if config.load(SAVE_PATH) != OK:
		Utils.crash("problem loading the config file !")
		return
	
	## Load progressions and settings
	for i in range(N_PROGRESSION):
		var progression = Progression.load_from_config_or_default(Save.config, _get_progression_section_name(i), Progression.new())
		progressions.push_back(progression)
	settings = Settings.load_from_config_or_default(config, SETTINGS_SECTION_NAME, Settings.new())
	save()
	TranslationServer.set_locale(settings.locale)


static func save():
	settings.save_to_config(config, SETTINGS_SECTION_NAME)
	for i in range(progressions.size()):
		progressions[i].save_to_config(config, _get_progression_section_name(i))
	config.save(SAVE_PATH)


static func _get_progression_section_name(index: int) -> String:
	return "progression_" + str(index)
