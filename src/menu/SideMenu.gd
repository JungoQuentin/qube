extends CanvasLayer

var current_menu: VBoxMenu
const change_menu_buttons_name = ["Settings", "Extra", "SaveFiles", "MovementSettings", "DisplaySettings", "Controls", "Language"]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	## Set Language
	var template_button = $Main/Quit
	var languages = Array(TranslationServer.get_loaded_locales())
	languages.map(func(lang: String):
		var new_button = template_button.duplicate()
		new_button.name = lang
		new_button.text = lang
		$Language.add_child(new_button)
	)
	
	## Set SaveFiles
	for i in range(LevelManager.N_PROGRESSION):
		var button = template_button.duplicate()
		button.name = "Save" + str(i)
		$SaveFiles.add_child(button)
		button.owner = $SaveFiles
	set_current_save_file(Save.settings.save_file)

	## Connect buttons
	get_children().map(func(menu: Control):
		if menu != $Main:
			var back_button = Button.new()
			back_button.text = "<"
			back_button.name = "Back"
			#back_button.theme = "SideButton"
			back_button.theme_type_variation = "SideButton"
			menu.add_child(back_button)
		menu.hide()
		if menu.get_child_count() == 0:
			return
		menu.get_child(0).focus_mode = Control.FOCUS_ALL
		menu.get_children().map(func(button):
			if button is Button: 
				button.pressed.connect(func(): click(button.name))
		)
	)
	
	$Settings/UnlockAllPuzzles.text = "ABORT_UNLOCK_ALL_PUZZLES" if LevelManager.get_current_progression().all_puzzle_unlocked else "UNLOCK_ALL_PUZZLES"
	
	hide()
	$Main.show()
	current_menu = $Main


func click(button_name: String):
	if button_name in change_menu_buttons_name:
		go_to_sub_menu(button_name)
		return
	
	## change save file
	if button_name.begins_with("Save"):
		var index = int(button_name.replace("Save", ""))
		set_current_save_file(index)
		go_to_parent_menu()
		return
	
	## change language
	if button_name in TranslationServer.get_loaded_locales():
		TranslationServer.set_locale(button_name)
		Save.settings.locale = button_name
		Save.save()
		go_to_parent_menu()
		return
	
	{
		"Resume": func(): toggle_settings(),
		"ReturneToTitle": func(): get_tree().change_scene_to_file("res://src/menu/Title.tscn"); toggle_settings(),
		"Quit": func(): get_tree().quit(),
		"Back": func(): go_to_parent_menu(),
		"UnlockAllPuzzles": toggle_unlock_all_puzzles
	}[button_name].call()


func toggle_unlock_all_puzzles():
	var to = $Settings/UnlockAllPuzzles.text == "UNLOCK_ALL_PUZZLES"
	$Settings/UnlockAllPuzzles.text = "ABORT_UNLOCK_ALL_PUZZLES" if to else "UNLOCK_ALL_PUZZLES"
	LevelManager.get_current_progression().all_puzzle_unlocked = to
	Save.save()
	go_to_parent_menu()


func set_current_save_file(index: int):
	Save.settings.save_file = index
	Save.save()
	for i in range(LevelManager.N_PROGRESSION):
		var button_name = "Save" + str(i)
		var button = $SaveFiles.find_child(button_name)
		var text = ""
		if i == index:
			text = "> "
		button.text = text + tr("SAVE") + " " + str(i) # TODO -> update when language changes


func toggle_settings(to:= not visible):
	visible = to
	get_tree().paused = visible
	if visible:
		$Main.get_child(0).grab_focus()
		$Main/ReturneToTitle.disabled = get_tree().current_scene is Title


func go_to_sub_menu(submenu_name: String):
	if not find_child(submenu_name, false):
		Utils.unimplemented(submenu_name)
		return
	current_menu.hide()
	current_menu = find_child(submenu_name, false)
	current_menu.show()
	current_menu.get_child(0).grab_focus()


func go_to_parent_menu():
	var last_menu_name = current_menu.name
	current_menu.hide()
	current_menu = current_menu.parent_menu
	current_menu.show()
	current_menu.find_child(last_menu_name).grab_focus()


func _input(_event):
	if Input.is_action_just_pressed("settings"):
		if not current_menu.parent_menu:
			toggle_settings()
		else:
			go_to_parent_menu()
