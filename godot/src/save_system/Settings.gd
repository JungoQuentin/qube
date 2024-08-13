class_name Settings extends Savable

enum UIScale {
	SMALLER,
	SMALL,
	MEDIUM,
	LARGE,
	LARGER,
}

var save_file: int # 0, 1, 2
var music_volume: int # 0 to 10
var sound_volume: int # 0 to 10
var locale: String # "fr", "en", ...
var is_fullscreen: bool
var msaa: Viewport.MSAA
var ui_scale: UIScale
var resolution_scale: float

func _init(
	_save_file:= 0, 
	_music_volume:= 8,
	_sound_volume:= 8,
	_locale:= "fr",
	_is_fullscreen:= false,
	_msaa:= Viewport.MSAA_DISABLED, # TODO Viewport.MSAA_8X,
	_ui_scale:= UIScale.MEDIUM,
	_resolution_scale:= 0.8, # TODO 1.0,
):
	save_file = _save_file
	music_volume = _music_volume
	sound_volume = _sound_volume
	locale = _locale
	is_fullscreen = _is_fullscreen
	msaa = _msaa
	ui_scale = _ui_scale
	resolution_scale = _resolution_scale

func apply(tree: SceneTree):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	#DisplayServer.window_set_size(resolution_to_vec2i(screen_resolution)) 
	TranslationServer.set_locale(locale)
	if tree.current_scene is BaseLevel:
		var viewport = tree.current_scene.get_viewport() 
		viewport.msaa_3d = msaa
		viewport.scaling_3d_scale = resolution_scale
		#tree.root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	var new_size = Save.viewport_start_size * {
		# TODO test different scale (try ingame)
		UIScale.SMALLER: 1.5,
		UIScale.SMALL: 1.25,
		UIScale.MEDIUM: 1.0,
		UIScale.LARGE: 0.75,
		UIScale.LARGER: 0.5,
	}[ui_scale]
	tree.root.set_content_scale_size(new_size)



	# TODO everythings there
