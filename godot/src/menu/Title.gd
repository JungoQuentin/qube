extends Control
class_name Title


func _input(_event):
	if Input.is_key_pressed(KEY_ENTER):
		LevelManagerRS.goto_level_gate(get_tree())
