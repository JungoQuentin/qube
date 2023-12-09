extends EditorInspectorPlugin
class_name QubeEditorInspectorPlugin


func _can_handle(object):
	return object is Cube


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name != "cubeType":
		return false
	add_property_editor(name, QubeTypeEditorProperty.new())
	return true
