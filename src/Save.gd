extends Node

var config = ConfigFile.new()
const save_path = &"res://save.cfg"
#const save_path = &"user://save.cfg"
signal loaded

func _ready():
	if not FileAccess.file_exists(save_path):
		config.save(save_path)
	if config.load(save_path) != OK:
		printerr("ooh, TODO")
	loaded.emit()


func save():
	config.save(save_path)
