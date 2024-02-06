extends Control
class_name Title


func _input(_event):
	if Input.is_key_pressed(KEY_ENTER):
		LevelManager.goto_level_gate()
