extends EditorProperty
class_name QubeTypeEditorProperty


var updating = false
var vbox = VBoxContainer.new()
var current_key: String
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
	for key in Cube.Type.keys():
		var button = Button.new()
		button.text = key
		vbox.add_child(button)
		button.pressed.connect(func(): change_cube_type(key))
	add_child(vbox)
	var selected = EditorPlugin.new().get_editor_interface().get_selection().get_selected_nodes()[0]
	var type = Cube.object_to_type(selected)
	current_key = Cube.Type.keys()[type]


func change_cube_type(key: String):
	if updating:
		return
	current_key = key
	emit_changed(get_edited_property(), Cube.Type[key])


func _update_property():
	updating = true
	var edited_property = get_edited_property()
	var object = get_edited_object()
	object.set_script(cube_preload[Cube.Type[current_key]])
	var new_value = object[edited_property]
	change_color(object)
	set_current_button(current_key, "update")
	updating = false


func change_color(object: Object):
	if not object is Cube:
		return
	var mesh_instance: MeshInstance3D = object.find_child("MeshInstance3D")
	mesh_instance.set_surface_override_material(0, mesh_instance.get_surface_override_material(0).duplicate(true))
	mesh_instance.get_surface_override_material(0).albedo_color = Colors.get_initial_color(Cube.object_to_type(object))


func set_current_button(key: String, caller = "null"):
	for button in vbox.get_children():
		var color = Color.LIGHT_GRAY if button.text != key else Color.AQUA
		button.add_theme_color_override("font_color", color)
		button.add_theme_color_override("font_focus_color", color)
		button.add_theme_color_override("font_hover_color", color)
		button.add_theme_color_override("font_pressed_color", color)
