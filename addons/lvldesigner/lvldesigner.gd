@tool extends EditorPlugin

var dock: BaseButton
var _editor_interface: EditorInterface

func _enter_tree():
	_editor_interface = get_editor_interface()
	dock = preload("res://addons/lvldesigner/GoBack.tscn").instantiate()
	scene_changed.connect(_scene_changed)
	dock.pressed.connect(_clicked)

	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)

func _clicked():
	print(_editor_interface.get_open_scenes())
	_editor_interface.get_open_scenes().clear()

func _scene_changed(_d):
	pass


func _exit_tree():
	print("exit_tree")
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()