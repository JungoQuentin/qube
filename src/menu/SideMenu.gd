extends CanvasLayer

var current_menu: VBoxMenu
const CHANGE_MENU_BUTTONS_NAME = ["Settings", "Extra", "SaveFiles", "MovementSettings", "DisplaySettings", "Controls", "Language"]


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var template_button = $Main/Quit
	
	## Set Language
	Save.available_languages.map(func(lang: String):
		var new_button = template_button.duplicate()
		new_button.name = lang
		new_button.text = lang
		$Language.add_child(new_button)
	)
	
	## Set SaveFiles
	for i in range(Save.N_PROGRESSION):
		var button = template_button.duplicate()
		button.name = "Save" + str(i)
		$SaveFiles.add_child(button)
		button.owner = $SaveFiles

	## Connect
	get_children().map(func(menu: Control):
		if menu != $Main:
			var back_button = Button.new()
			back_button.text = "<"
			back_button.name = "Back"
			back_button.theme_type_variation = "SideButton"
			menu.add_child(back_button)
		menu.hide()
		if menu.get_child_count() == 0:
			return
		menu.get_child(0).focus_mode = Control.FOCUS_ALL
		menu.get_children(). \
			filter(func(item): return item is Button and not item is SBBaseButton). \
			map(func(button):
				button.pressed.connect(func(): _click_button(button.name))
		)
		menu.get_children(). \
			filter(func(item): return item is SBCheckboxButton). \
			map(func(button):
				button.pressed.connect(func(): _click_checkbox(button.name))
		)
		menu.get_children(). \
			filter(func(item): return item is SBSpinButton). \
			map(func(spin: SBSpinButton):
				spin.item_selected.connect(func(index): _change_spin(spin.name, index))
		)		
		menu.get_children(). \
			filter(func(item): return item is SliderInput). \
			map(func(slider: SliderInput):
				slider.value_changed.connect(func(value): _change_slider(value, slider.setting_name))
		)
	)
	
	_update_ui_from_settings()
	hide()
	$Main.show()
	current_menu = $Main


func _input(_event):
	if Input.is_action_just_pressed("settings"):
		if not current_menu.parent_menu:
			_toggle_settings()
		else:
			_go_to_parent_menu()

#region Changes handlers

func _click_button(button_name: String):
	## go to submenu
	if button_name in CHANGE_MENU_BUTTONS_NAME:
		if not find_child(button_name, false):
			Utils.unimplemented(button_name)
			return
		current_menu.hide()
		current_menu = find_child(button_name, false)
		current_menu.show()
		current_menu.get_child(0).grab_focus()
		return
	
	## change save file
	if button_name.begins_with("Save"):
		if get_tree().current_scene is BaseLevel:
			get_tree().change_scene_to_file("res://src/menu/Title.tscn")
		var index = int(button_name.replace("Save", ""))
		Save.settings.save_file = index
		Save.save()
		_go_to_parent_menu()
		_update_ui_from_settings()
		return
	
	## change language
	if button_name in TranslationServer.get_loaded_locales():
		TranslationServer.set_locale(button_name)
		Save.settings.locale = button_name
		Save.save()
		_go_to_parent_menu()
		_update_ui_from_settings()
		return
	
	{
		"Resume": _toggle_settings,
		"ReturneToTitle": func(): 
			get_tree().change_scene_to_file("res://src/menu/Title.tscn")
			_toggle_settings()
			,
		"Quit": func(): get_tree().quit(),
		"Back": _go_to_parent_menu,
	}[button_name].call()


func _click_checkbox(button_name: String):
	{
		"Fullscreen": func(): 
			Save.settings.is_fullscreen = $DisplaySettings/Fullscreen.get_checked()
			,
		"UnlockAllPuzzles": func():
			LevelManager.get_current_progression().all_puzzle_unlocked = ($Settings/UnlockAllPuzzles as SBCheckboxButton).get_checked()
			Save.save()
			_go_to_parent_menu()
			,
	}[button_name].call()
	Save.settings.apply(get_tree())
	Save.save()


func _change_spin(spin_name: String, index: int):
	{
		"Msaa": func():
			Save.settings.msaa = index as Viewport.MSAA,
		"UIScale": func():
			Save.settings.ui_scale = index as Settings.UIScale
	}[spin_name].call()
	Save.settings.apply(get_tree())
	Save.save()


func _change_slider(new_value, setting_name:= ""):
	if not setting_name.is_empty():
		Save.settings.set(setting_name, new_value)
		Save.settings.apply(get_tree())
		Save.save()
	else:
		Utils.unimplemented()

#endregion

#region UI updates
func _toggle_settings(to:= not visible):
	visible = to
	get_tree().paused = visible
	if visible:
		$Main.get_child(0).grab_focus()
		$Main/ReturneToTitle.disabled = get_tree().current_scene is Title


func _go_to_parent_menu():
	var last_menu_name = current_menu.name
	current_menu.hide()
	current_menu = current_menu.parent_menu
	current_menu.show()
	current_menu.find_child(last_menu_name).grab_focus()


func _update_ui_from_settings():
	($DisplaySettings/UIScale as SBSpinButton).select(Save.settings.ui_scale)
	($DisplaySettings/Fullscreen as SBCheckboxButton).set_checked(Save.settings.is_fullscreen)
	($DisplaySettings/Msaa as SBSpinButton).select(Save.settings.msaa)
	($Settings/UnlockAllPuzzles as SBCheckboxButton).set_checked(LevelManager.get_current_progression().all_puzzle_unlocked)
	## Save file
	for i in range(Save.N_PROGRESSION):
		var button = $SaveFiles.find_child("Save" + str(i))
		var text = ""
		if i == Save.settings.save_file:
			text = "> "
		button.text = text + tr("SAVE") + " " + str(i)

#endregion
