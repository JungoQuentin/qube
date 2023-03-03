@tool
extends EditorPlugin
class_name BCubePlugin

var dock: VBoxContainer
var editor_interface: EditorInterface
var lvl_editor_scene: Node3D
var dimension: int = 0
var lvl_name_input: LineEdit

func _enter_tree():
	editor_interface = get_editor_interface()
	_init_dock()
	Tools.plugin = self

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()

func _test_level():
	if not _is_lvl_maker_current():
		_go_to_lvl_editor()
		return
	if not _args_valid(true, dimension, ""):
		return
	lvl_editor_scene.test(dimension)

func _save_level():
	if not _is_lvl_maker_current():
		_go_to_lvl_editor()
		return
	if not _args_valid(false, dimension, lvl_name_input.text):
		return
	lvl_editor_scene.save(dimension, lvl_name_input.text)

func _args_valid(_test: bool, dimension, lvl_name) -> bool:
	if dimension == 0 or dimension % 2 == 0 or dimension < 3:
		Tools.alert("mauvaise dimension (0 ou pair, doit commencer a 3)")
		print("end alert")
		return false
	if not _test and lvl_name.length() == 0:
		Tools.alert("faut donner un nom au niveau...")
		return false
	return true

func _add_h_sep(n=30):
	var n_sep = HSeparator.new()
	n_sep.custom_minimum_size.y = n
	dock.add_child(n_sep)

func _init_dock():
	dock = VBoxContainer.new()
	dock.name = "LvlMakerPlugin"
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)

	##### 

	var dim_label = Label.new()
	dim_label.text = "dimension"
	var dim_box = HBoxContainer.new()
	dock.add_child(dim_box)
	dim3 = _add_button("3", dim_box, func(): set_dimension(3))
	dim5 = _add_button("5", dim_box, func(): set_dimension(5))
	dim7 = _add_button("7", dim_box, func(): set_dimension(7))

	lvl_name_input = _add_intut("lvl name")
	_add_button("Tester le niveau", dock, _test_level)
	_add_button("Sauvegarder le niveau", dock, _save_level)
	_add_h_sep()

	##########

	var adder = HBoxContainer.new()
	dock.add_child(adder)
	for template_name in DirAccess.open(Tools.TEMPLATES_PATH).get_files():
		_add_button("add " + template_name.split('.')[0], adder, func(): if _is_lvl_maker_current(): lvl_editor_scene.add_template(template_name) else: _go_to_lvl_editor())
	# _add_h_sep()
	# _add_h_sep()
	# _add_button("go to colors", dock, func(): editor_interface.open_scene_from_path("res://src/auto_loads/Colors.tscn"))

var dim3
var dim5
var dim7
func set_dimension(n):
	if not [3, 5, 7].has(n):
		return
	dimension = n
	[dim3, dim5, dim7].map(func(button): button.custom_minimum_size.x = 0)
	var to_focus: Button = get("dim{}".format([n], '{}'))
	to_focus.custom_minimum_size.x = 70


func _add_button(_name, parent, callback):
	var n_button = Button.new()
	n_button.text = _name
	n_button.name = _name
	n_button.pressed.connect(callback)
	parent.add_child(n_button)
	return n_button

func _add_intut(_name, number=false) -> LineEdit:
	var n_input: LineEdit = LineEdit.new()
	n_input.name = _name
	if number:
		n_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	n_input.placeholder_text = _name
	n_input.custom_minimum_size.y = 30
	dock.add_child(n_input)
	return n_input

func _clicked():
	print(editor_interface.get_open_scenes())
	editor_interface.get_open_scenes().clear()
	editor_interface.stop_playing_scene()

func _go_to_lvl_editor():
	if not _is_lvl_maker_current():
		editor_interface.open_scene_from_path(Tools.LVL_DESIGNER_PATH)

func _is_lvl_maker_current():
	return lvl_editor_scene == editor_interface.get_edited_scene_root()