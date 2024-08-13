@tool extends Node

@onready var _color_set: ColorSet = load("res://colors/color_set_power.tres")

func get_initial_color(cubeType: Cube.Type) -> Color:
	return _color_set.get_initial_color(cubeType)
