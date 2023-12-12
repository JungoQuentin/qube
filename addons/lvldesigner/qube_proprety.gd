extends EditorProperty
class_name QubeTypeEditorProperty


var _updating = false
var _vbox = VBoxContainer.new()
var _current_key: String
var _first_update:= false
@onready var cube_preload: Dictionary = {
	Cube.Type.NORMAL : NormalCube,
	Cube.Type.BLOCKING : BlockingCube,
	Cube.Type.END : EndCube,
	Cube.Type.SINGLE_USE: SingleUseCube,
	Cube.Type.MOVING: MovingCube,
	Cube.Type.SWITCH: SwitchCube,
	Cube.Type.ICE: IceCube,
	Cube.Type.HOLE: HoleCube
}


func _init():
	var selected = EditorInterface.get_selection().get_selected_nodes()
	for key in Cube.Type.keys():
		var button = Button.new()
		button.text = key
		_vbox.add_child(button)
		button.pressed.connect(func(): _change_cube_type(key))
	add_child(_vbox)
	for cube in selected:
		var type = Cube.object_to_type(cube)
		_current_key = Cube.Type.keys()[type]
		_update_color(cube)
	_set_current_button(_current_key)


func _change_cube_type(key: String):
	if _updating:
		return
	_current_key = key
	emit_changed(get_edited_property(), Cube.Type[key])


func _update_property():
	if not _first_update:
		_first_update = true
		return
	_updating = true
	var edited_property = get_edited_property()
	for cube in EditorInterface.get_selection().get_selected_nodes():
		cube.set_script(cube_preload[Cube.Type[_current_key]])
		var new_value = cube[edited_property]
		_update_color(cube)
		_set_current_button(_current_key)
	_updating = false


func _update_color(object: Object):
	if not object is Cube:
		return
	var mesh_instance: MeshInstance3D = object.find_child("MeshInstance3D")
	mesh_instance.set_surface_override_material(0, mesh_instance.get_surface_override_material(0).duplicate(true))
	mesh_instance.get_surface_override_material(0).albedo_color = Colors.get_initial_color(Cube.object_to_type(object))


func _set_current_button(key: String):
	for button in _vbox.get_children():
		var color = Color.LIGHT_GRAY if button.text != key else Color.AQUA
		button.add_theme_color_override("font_color", color)
		button.add_theme_color_override("font_focus_color", color)
		button.add_theme_color_override("font_hover_color", color)
		button.add_theme_color_override("font_pressed_color", color)
