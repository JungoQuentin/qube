extends Control

@onready var buttons: VBoxContainer = $Buttons
#@onready var go_to_menu_button: Button = $Settings/GoToMenu
#@onready var go_to_level_gate_button: Button = $Settings/GoToLevelGateButton


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	buttons.get_children().map(func(button: Button): button.pressed.connect(func(): click(button.name)))
	hide()
	

func click(button_name: String):
	if button_name in ["Settings", "Extra", "SaveFiles"]:
		go_in_sub_menu(button_name)
		return
	{
		"Resume": func(): toggle_settings(),
		"ReturneToTitle": func(): get_tree().change_scene_to_file("res://src/menu/Title.tscn"),
		"Quit": func(): get_tree().quit(),
	}[button_name].call()


func go_in_sub_menu(submenu_name: String):
	print(submenu_name)

func toggle_settings(to:= not visible):
	visible = to
	get_tree().paused = visible
	if visible:
		buttons.get_child(0).grab_focus()
		$Buttons/ReturneToTitle.disabled = get_tree().current_scene is Title
		


func _input(_event):
	if Input.is_action_just_pressed("settings"):
		toggle_settings()
	if not visible:
		return
	#if Input.is_action_just_pressed("ui_down"):
		#print("down")
