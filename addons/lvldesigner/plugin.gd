@tool
extends EditorPlugin
class_name QubePlugin

var _plugin_dock: VBoxContainer
var dimension:= Vector3i.ONE * 3
var editorPlugin
var _level_file_regex = RegEx.create_from_string("(?<digit>[0-9]+)(_*)(?<name>\\w*)\\.tscn")
@onready var normalCubePreload = preload("res://src/levels/cubeTypes/Cube.tscn");
const LEVEL_PATH = &"res://src/levels"
const LEVEL_MANAGER_PATH = &"res://src/levels/LevelManager.tscn"

func _enter_tree():
	editorPlugin = preload("res://addons/lvldesigner/editor_plugin.gd").new()
	add_inspector_plugin(editorPlugin)
	scene_changed.connect(func(_node): _update_cubes_color())
	_init_dock()


func _exit_tree():
	remove_control_from_docks(_plugin_dock)
	remove_inspector_plugin(editorPlugin)
	_plugin_dock.free()


func _init_dock():
	_plugin_dock = VBoxContainer.new()
	_plugin_dock.name = "LvlMaker"
	add_control_to_dock(DOCK_SLOT_LEFT_UL, _plugin_dock)
	
	var create_dock = HBoxContainer.new()
	_plugin_dock.add_child(create_dock)
	var dimensions_input = _add_intut("3(x3x3)", create_dock, false)
	_add_button("creer", create_dock, func(): create_map(dimensions_input.text))

	_add_button("auto levels", _plugin_dock, _auto_fill_level_manager)


func _update_cubes_color():
	var scene = EditorInterface.get_edited_scene_root()
	if scene == null:
		return
	var map_cube: Node3D = scene.find_child("MapCube", true, false)
	if map_cube == null:
		return
	for cube in map_cube.get_children():
		var mesh_instance: MeshInstance3D = cube.find_child("MeshInstance3D")
		var initial_color = Colors.get_initial_color(cube)
		mesh_instance.set_surface_override_material(0, mesh_instance.get_surface_override_material(0).duplicate(true))
		mesh_instance.get_surface_override_material(0).albedo_color = initial_color


func _auto_fill_level_manager():
	var scene = EditorInterface.get_edited_scene_root()
	if scene == null or scene.name != "LevelManager":
		EditorInterface.open_scene_from_path(LEVEL_MANAGER_PATH)
		scene = EditorInterface.get_edited_scene_root()

	var files = DirAccess.get_files_at(LEVEL_PATH)
	var level_matches: Array = Array(files) \
		.map(func(file): return _level_file_regex.search(file)) \
		.filter(func(m): return m)
	var level_paths = level_matches.map(func(m): return load(LEVEL_PATH + "/" + m.get_string()))
	scene.levels = level_paths


#region CREATE MAP

func create_map(n: String):
	var scene = EditorInterface.get_edited_scene_root()

	if scene == null:
		_alert("Il faut se rendre dans un niveau", "Pas dans un niveau")
		return
	var map_cube: Node3D = scene.find_child("MapCube", true, false)
	if map_cube == null:
		_alert("Il faut se rendre dans un niveau", "Pas dans un niveau")
		return

	var dimension_numbers = n.split('x')
	if dimension_numbers.size() == 1:
		dimension = Vector3i.ONE * int(dimension_numbers[0])
	elif dimension_numbers.size() == 3:
		dimension.x = int(dimension_numbers[0])
		dimension.y = int(dimension_numbers[1])
		dimension.z = int(dimension_numbers[2])
	else:
		_alert("Faut formater comme ca: '3x1x3' ou comme ca: '3'", "Mauvais formatage - dimension")

	#map_cube.dimension = dimension # TODO -> pour la camera: changer de zoom a chaque fois ??
	
	var vector = Vector3i.ZERO
	for x in range(dimension.x):
		vector.x = x - int(dimension.x / 2)
		for y in range(dimension.y):
			vector.y = y - int(dimension.y / 2)
			for z in range(dimension.z):
				vector.z = z - int(dimension.z / 2)
				if z == 0 or y == 0 or x == 0 or y == dimension.y - 1 or x == dimension.x - 1 or z == dimension.z - 1:
					_add_cube(vector, map_cube, normalCubePreload.instantiate(), "name", scene)
	_update_cubes_color()

func _add_cube(new_position: Vector3i, parent: Node3D, object: Node3D, new_name: String, scene: Node3D):
	object.position = new_position
	object.visible = true
	object.name = new_name
	_add_and_set_own(object, parent, scene)

#endregion

#region UI HELPERS

func _add_button(_name, parent, callback):
	var n_button = Button.new()
	n_button.text = _name
	n_button.name = _name
	n_button.pressed.connect(callback)
	parent.add_child(n_button)
	return n_button


func _add_intut(new_name, parent, is_number) -> LineEdit:
	var n_input: LineEdit = LineEdit.new()
	n_input.name = new_name
	if is_number:
		n_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	n_input.placeholder_text = new_name
	n_input.custom_minimum_size.y = 30
	parent.add_child(n_input)
	return n_input


func _add_h_sep(n=30):
	var n_sep = HSeparator.new()
	n_sep.custom_minimum_size.y = n
	_plugin_dock.add_child(n_sep)

#endregion

#region UTILS

func _add_and_set_own(node, parent, _owner):
	parent.add_child(node)
	if _owner != null:
		node.set_owner(_owner)


func _alert(msg: String, title: String="alert"):
	OS.alert(msg, title)

#endregion
