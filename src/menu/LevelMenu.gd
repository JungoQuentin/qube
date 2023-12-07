extends Control


@onready var buttons_container = $ButtonsVBoxContainer
@onready var demo_button = $ButtonsVBoxContainer/DemoButton


func _ready():
	_create_level_buttons()


func _create_level_buttons(): 
	var i = 0
	for level in LevelManager.levels:
		var new_button = demo_button.duplicate()
		new_button.text = "level %d" % i
		new_button.connect("pressed", func(): LevelManager.goto_level_by_index(i))
		buttons_container.add_child(new_button)
		i += 1
		
	demo_button.queue_free()
