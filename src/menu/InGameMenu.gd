extends Control


@onready var go_to_menu_button = $GoToMenuButton


func _ready():
	go_to_menu_button.connect("pressed", func(): get_tree().change_scene_to_file("res://src/menu/LevelMenu.tscn"))
