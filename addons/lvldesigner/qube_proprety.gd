extends EditorProperty


var updating = false
var vbox = VBoxContainer.new()
var current_key: String
@onready var cube_preload: Dictionary = {
	Cube.Type.NORMAL : preload("res://src/cubeTypes/normalCube.gd"),
	Cube.Type.BLOCKING : preload("res://src/cubeTypes/blockingCube.gd"),
	Cube.Type.START : preload("res://src/cubeTypes/startCube.gd"),
	Cube.Type.END : preload("res://src/cubeTypes/endCube.gd"),
	Cube.Type.SINGLE_USE: preload("res://src/cubeTypes/singleUseCube.gd"),
	Cube.Type.MOVING: preload("res://src/cubeTypes/movingCube.gd"),
	Cube.Type.SWITCH: preload("res://src/cubeTypes/switchCube.gd"),
	Cube.Type.ICE: preload("res://src/cubeTypes/IceCube.gd")
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
	var new_mesh = mesh_instance.mesh.duplicate(true)
	mesh_instance.mesh = new_mesh
	var initial_color = Colors.get_initial_color(object)
	new_mesh.surface_get_material(0).albedo_color = initial_color


func set_current_button(key: String, caller = "null"):
	for button in vbox.get_children():
		var color = Color.LIGHT_GRAY if button.text != key else Color.AQUA
		button.add_theme_color_override("font_color", color)
		button.add_theme_color_override("font_focus_color", color)
		button.add_theme_color_override("font_hover_color", color)
		button.add_theme_color_override("font_pressed_color", color)
