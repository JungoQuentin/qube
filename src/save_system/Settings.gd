class_name Settings extends Savable

var save_file: int # 0, 1, 2
var music_volume: int # 0 to 10
var sound_volume: int # 0 to 10
var locale: String # "fr", "en", ...

func _init(
	_save_file:= 0, 
	_music_volume:= 8,
	_sound_volume:= 8,
	_locale:= "fr",
):
	save_file = _save_file
	music_volume = _music_volume
	sound_volume = _sound_volume
	locale = _locale
