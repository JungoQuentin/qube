@tool extends Node

@export_category("Palette")
@export var palette_name = "default"
@export_subgroup("Control")
@export var load_palette = false:
	set(_v):
		load_color_palette(palette_name)
@export var save_palette = false:
	set(_v):
		save_color_palette(palette_name)
@export var save_palette_override = false:
	set(_v):
		save_color_palette(palette_name, true)
@export_group("Colors")
@export_subgroup("Player")
@export var player_color = Color.WHITE
@export var player_fade = false
@export_subgroup("Environment")
@export var inner_light_color = Color.WHITE
@export var background_color = Color.BLACK
@export var inner_light_fade = false 
@export_range(0., 5.) var fade_from = 0.5
@export_range(1., 10.) var fade_to = 2.
@export_range(0.5, 10.) var fade_speed = 2.
@export_subgroup("Cubes")
@export var normal_init_color = Color.REBECCA_PURPLE
@export var blocking_init_color = Color.DARK_GRAY
@export var single_cube_init_color = Color.DARK_GRAY
@export var end_cube_init_color = Color.DARK_GRAY
@export var switch_cube_on_color = Color.YELLOW
@export var switch_cube_off_color = Color.BLACK
@export var moving_cube_init_color = Color.YELLOW
@export var ice_cube_init_color = Color.LIGHT_SKY_BLUE
@export var hole_cube_editor_color = Color.AZURE
@export_group("Others")
@export_range(0, 1) var cube_scale: float = 0.965

var property_list: Dictionary

func _ready():
	if Engine.is_editor_hint(): _ready_on_editor()


func get_initial_color(cubeType: Cube.Type) -> Color:
	match cubeType:
		Cube.Type.NORMAL: return normal_init_color
		Cube.Type.BLOCKING: return blocking_init_color
		Cube.Type.END: return end_cube_init_color
		Cube.Type.SINGLE_USE: return single_cube_init_color
		Cube.Type.MOVING: return moving_cube_init_color
		Cube.Type.ICE: return ice_cube_init_color
		Cube.Type.HOLE: return hole_cube_editor_color
	return normal_init_color


func _ready_on_editor():
	_set_property_list()

func _color_path(_name: String):
	return "res://colors/color_palette_" + _name + ".cfg"

func save_color_palette(_name: String, override=false):
	if not override and FileAccess.file_exists(_color_path(_name)):
		print("Color palette already exists: " + _name + "")
		return
	var config = ConfigFile.new()
	for key in property_list.keys():
		config.set_value("Colors", key, get(key))
	config.save(_color_path(_name))

func load_color_palette(_name: String):
	var config = ConfigFile.new()
	if config.load(_color_path(_name)) != OK:
		print("Error while loading color palette: " + _name + "")
		return
	for key in property_list.keys():
		property_list[key] = config.get_value("Colors", key)
		set(key, property_list[key])

func darker(_color: Color, _dark_factor: float=0.8, _saturation_factor: float=2):
	#return Color.from_hsv(_color.h, 1, _color.v * _dark_factor)
	return Color.from_hsv(_color.h, _color.s * _saturation_factor, _color.v * _dark_factor)






func _set_property_list():
	var property_names = get_script().get_script_property_list().filter(_is_palette_var).map(func(prop): return prop["name"])
	property_names.map(func(prop_name): property_list[prop_name] = get(prop_name) )

func _is_palette_var(prop):
	var unwanted_export = ["palette_name", "load_palette", "save_palette", "save_palette_override", "property_list"]
	return prop["usage"] > 4000 and not unwanted_export.any(func(unw): return prop["name"] == unw)
