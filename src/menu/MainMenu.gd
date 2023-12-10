extends Node

@onready var begin_button = $ButtonsVBoxContainer/BeginButton
@onready var level_button = $ButtonsVBoxContainer/LevelButton

func _ready():
	begin_button.connect("pressed", func(): LevelManager.goto_level_by_index(0))
	level_button.connect("pressed", func(): get_tree().change_scene_to_file("res://src/menu/LevelMenu.tscn"))
