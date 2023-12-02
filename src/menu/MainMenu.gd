extends Node

@onready var begin_button = $ButtonsVBoxContainer/BeginButton
@onready var level_button = $ButtonsVBoxContainer/LevelButton

func _ready():
	begin_button.connect("pressed", func(): get_tree().change_scene_to_file("res://src/levels/000.tscn"))
	level_button.connect("pressed", func(): get_tree().change_scene_to_file("res://src/menu/LevelMenu.tscn"))
