@tool
extends Resource
class_name ColorSet

const CURRENT_COLOR_SET = "res://colors/color_set_power.tres"

@export_category("Palette")
@export var palette_name = "default"
@export_subgroup("Control")
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
@export var snow_ball_init_color = Color.WHITE
@export var ice_cube_init_color = Color.LIGHT_SKY_BLUE
@export var hole_cube_editor_color = Color.AZURE
@export var gate_init_color = Color.DARK_CYAN
@export var laser_cube_init_color = Color.LIGHT_CORAL
@export_group("Others")
@export_range(0, 1) var cube_scale: float = 0.965


static func darker(_color: Color, _dark_factor: float=0.8, _saturation_factor: float=2):
	return Color.from_hsv(_color.h, _color.s * _saturation_factor, _color.v * _dark_factor)


func get_initial_color(cubeType: Cube.Type) -> Color:
	return {
		Cube.Type.BLOCKING: blocking_init_color,
		Cube.Type.GATE: gate_init_color,
		Cube.Type.END: end_cube_init_color,
		Cube.Type.SINGLE_USE: single_cube_init_color,
		Cube.Type.SNOW_BALL: snow_ball_init_color,
		Cube.Type.ICE: ice_cube_init_color,
		Cube.Type.HOLE: hole_cube_editor_color,
		Cube.Type.SWITCH: switch_cube_on_color,
		Cube.Type.NORMAL: normal_init_color,
		Cube.Type.LASER: laser_cube_init_color,
	}[cubeType]


static func static_get_initial_color(cubeType: Cube.Type, res: ColorSet) -> Color:
	return res.get_initial_color(cubeType)
