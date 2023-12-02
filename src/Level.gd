class_name Level extends Node3D

#region DECLARATION

enum { INGAME, PAUSE, MENU }
var game_state = INGAME

signal level_initialized

@onready var player: Node3D = $Player
@onready var map_cube: MapCube = $MapCube
@onready var in_game_menu: Control = preload("res://src/menu/InGameMenu.tscn").instantiate()
@onready var camera: Camera3D = preload("res://src/env/Camera.tscn").instantiate()
var startCube: Cube
var switch_cubes: Array
var single_use_cubes: Array
var moving_cubes: Array

#endregion


func _ready():
	add_child(in_game_menu)
	add_child(camera)
	_init_action_stack_display()
	_init_map()
	level_initialized.emit()

## init the map by getting all the special cubes
func _init_map():
	var map_cube_children = map_cube.get_child(0).get_children()
	switch_cubes = map_cube_children.filter(func(cube): return cube is SwitchCube)
	single_use_cubes = map_cube_children.filter(func(cube): return cube is SingleUseCube)
	moving_cubes = map_cube_children.filter(func(cube): return cube is MovingCube)
	moving_cubes.map(func(cube): Utils.switch_parent(cube, get_tree().get_current_scene()))


func check_all_switch_state():
	if switch_cubes.all(func(cube): return cube.on):
		print("ALL TRUE !")
		# TODO

#region Debug

# var action_stack_display: VBoxContainer
# var undo_stack_display: VBoxContainer
# ## only for debug purpose
# ## will display the stack of the player actions (inputs)
func _init_action_stack_display():
	pass
# 	action_stack_display = VBoxContainer.new()
# 	add_child(action_stack_display)
# 	undo_stack_display = VBoxContainer.new()
# 	undo_stack_display.anchor_left = 0.5
# 	add_child(undo_stack_display)

func update_stack_display():
	pass
# 	action_stack_display.get_children().map(func(child): child.queue_free())
# 	undo_stack_display.get_children().map(func(child): child.queue_free())
# 	for action in ActionSystem.actions:
# 		_add_action_to_stack_display(action)
# 	for action in ActionSystem.undo_stack:
# 		_add_action_to_stack_display(action, true)

func _add_action_to_stack_display(action: Action, is_undo=false):
	pass
# 	var new_label = Label.new()
# 	new_label.text = str(action)
# 	if not is_undo:
# 		action_stack_display.add_child(new_label)
# 	else:
# 		undo_stack_display.add_child(new_label)

#endregion
