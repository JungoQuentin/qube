extends Control
class_name InGameMenu

@onready var settings: Control = $Settings
@onready var esc_settings_button: Button = $Settings/Esc
@onready var go_to_menu_button: Button = $Settings/GoToMenu
@onready var go_to_level_gate_button: Button = $Settings/GoToLevelGateButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	go_to_level_gate_button.pressed.connect(func(): get_tree().change_scene_to_file(&"res://src/levels/000_entry_point.tscn"))
	go_to_menu_button.pressed.connect(func(): get_tree().change_scene_to_file(&"res://src/menu/MainMenu.tscn"))
	settings.hide()
	esc_settings_button.pressed.connect(toggle_settings)
	go_to_level_gate_button.visible = not get_tree().current_scene.is_level_gate


func toggle_settings():
	settings.visible = not settings.visible
	get_tree().paused = not get_tree().paused


func _input(_event):
	if Input.is_action_just_pressed("settings"):
		toggle_settings()

func _exit_tree():
	get_tree().paused = false
