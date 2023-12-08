@tool
extends EditorPlugin
class_name QubePlugin

var dock: VBoxContainer
var editor_interface: EditorInterface
var dimension:= Vector3i.ONE * 3
var dimensions_input: LineEdit
var editorPlugin
@onready var normalCubePreload = preload("res://src/cubeTypes/normalCube.tscn");


func _enter_tree():
	editor_interface = get_editor_interface()
	editorPlugin = preload("res://addons/lvldesigner/editor_plugin.gd").new()
	add_inspector_plugin(editorPlugin)
	_init_dock()


func _exit_tree():
	remove_control_from_docks(dock)
	remove_inspector_plugin(editorPlugin)
	dock.free()


func _init_dock():
	dock = VBoxContainer.new()
	dock.name = "LvlMaker"
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	var dim_box = HBoxContainer.new()
	dock.add_child(dim_box)
	dimensions_input = _add_intut("dimension (ex: '3' pour cube et '3x1x3' pour rectangle)")
	_add_button("creer un terrain", dim_box, func(): create_map(dimensions_input.text))


#region CREATE MAP

func create_map(n: String):
	var scene = editor_interface.get_edited_scene_root()
	var map_cube: MapCube = scene.find_child("MapCube", true, false)
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
				print(vector)
				if z == 0 or y == 0 or x == 0 or y == dimension.y - 1 or x == dimension.x - 1 or z == dimension.z - 1:
					_add_cube(vector, map_cube, normalCubePreload.instantiate(), "name", scene)


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


func _add_intut(_name, number=false) -> LineEdit:
	var n_input: LineEdit = LineEdit.new()
	n_input.name = _name
	if number:
		n_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	n_input.placeholder_text = _name
	n_input.custom_minimum_size.y = 30
	dock.add_child(n_input)
	return n_input


func _add_h_sep(n=30):
	var n_sep = HSeparator.new()
	n_sep.custom_minimum_size.y = n
	dock.add_child(n_sep)

#endregion

#region UTILS

func _add_and_set_own(node, parent, _owner):
	parent.add_child(node)
	if _owner != null:
		node.set_owner(_owner)


func _alert(msg: String, title: String="alert"):
	OS.alert(msg, title)

#endregion
