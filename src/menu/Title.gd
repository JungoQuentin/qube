extends Node

@onready var begin_button = $ButtonsVBoxContainer/BeginButton
@onready var level_button = $ButtonsVBoxContainer/LevelButton
@onready var settings_button = $ButtonsVBoxContainer/SettingsButton

func _ready():
	begin_button.pressed.connect(LevelManager.goto_level_gate)
	level_button.pressed.connect(func(): get_tree().change_scene_to_file("res://src/menu/LevelMenu.tscn"))
	settings_button.pressed.connect(func(): print("settings"))
