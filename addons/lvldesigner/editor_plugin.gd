extends EditorInspectorPlugin

var CubeIntEditor = preload("res://addons/lvldesigner/qube_proprety.gd")


func _can_handle(object):
	return object is Cube


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name != "cubeType":
		return false
	add_property_editor(name, CubeIntEditor.new())
	return true
