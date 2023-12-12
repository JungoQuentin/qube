extends EditorInspectorPlugin
class_name QubeEditorInspectorPlugin


func _can_handle(object):
	# https://github.com/godotengine/godot-proposals/issues/8067
	if object.get_class() == "MultiNodeEdit":
		for node in EditorInterface.get_selection().get_selected_nodes():
			if not node is Cube:
				return false
		return true
	return object is Cube


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name != "cubeType":
		return false
	add_property_editor(name, QubeTypeEditorProperty.new())
	return true
