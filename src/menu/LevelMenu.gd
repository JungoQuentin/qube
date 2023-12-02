extends Node

@export var levels: Array[PackedScene]
@onready var buttons_container = $ButtonsVBoxContainer
@onready var demo_button = $ButtonsVBoxContainer/DemoButton

func _ready():
	demo_button.queue_free()

	var i = 1
	for level in levels:
		var new_button = Button.new()
		new_button.text = "level %d" % i
		new_button.connect("pressed", func(): get_tree().change_scene_to_packed(level))
		buttons_container.add_child(new_button)
		i += 1
