extends CanvasLayer

@onready var main: VBoxContainer = $Main
@onready var current_menu: VBoxContainer = $Main


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	main.get_children().map(func(button: Button): button.pressed.connect(func(): click(button.name)))
	hide()
	$Settings.hide()
	

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
	current_menu.hide()
	current_menu = find_child(submenu_name, false)
	current_menu.show()
	current_menu.get_child(0).grab_focus()


func toggle_settings(to:= not visible):
	visible = to
	get_tree().paused = visible
	if visible:
		main.get_child(0).grab_focus()
		$Main/ReturneToTitle.disabled = get_tree().current_scene is Title


func _input(_event):
	if Input.is_action_just_pressed("settings"):
		toggle_settings()
