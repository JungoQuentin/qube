## AutoLoad that manages the level
extends Node

signal level_initialized
enum { INGAME, PAUSE, MENU }

var game_state = INGAME
var player: Node3D
var map_cube: MapCube
var startCube: Cube
var switch_cubes: Array
var single_use_cubes: Array
var moving_cubes: Array

var current_level: Node3D
var action_stack_display: VBoxContainer
var undo_stack_display: VBoxContainer

func _ready():
	await _init_level()

### INIT ###

func _init_level():
	current_level = get_tree().get_current_scene()
	_init_action_stack_display()
	await _init_map()
	level_initialized.emit()

func _init_map():
	await Utils.wait_while(func(): return map_cube == null, 1)
	var map_cube_children = map_cube.get_child(0).get_children()
	switch_cubes = map_cube_children.filter(func(cube): return cube is SwitchCube)
	single_use_cubes = map_cube_children.filter(func(cube): return cube is SingleUseCube)
	moving_cubes = map_cube_children.filter(func(cube): return cube is MovingCube)
	moving_cubes.map(func(cube): Utils.switch_parent(cube, get_tree().get_current_scene()))

func _init_action_stack_display():
	action_stack_display = VBoxContainer.new()
	current_level.add_child(action_stack_display)
	undo_stack_display = VBoxContainer.new()
	undo_stack_display.anchor_left = 0.5
	current_level.add_child(undo_stack_display)

### STACK DISPLAY ###

func update_stack_display():
	action_stack_display.get_children().map(func(child): child.queue_free())
	undo_stack_display.get_children().map(func(child): child.queue_free())
	for action in ActionSystem.actions:
		_add_action_to_stack_display(action)
	for action in ActionSystem.undo_stack:
		_add_action_to_stack_display(action, true)

func _add_action_to_stack_display(action: Action, is_undo=false):
	var new_label = Label.new()
	new_label.text = str(action)
	if not is_undo:
		action_stack_display.add_child(new_label)
	else:
		undo_stack_display.add_child(new_label)

### LEVEL ###

func check_all_switch_state():
	if switch_cubes.all(func(cube): return cube.on):
		print("ALL TRUE !")
		# TODO

func clear_level():
	player.queue_free()
	map_cube.queue_free()
	startCube.queue_free()
	switch_cubes.clear()
	single_use_cubes.clear()
	moving_cubes.clear()
	current_level = null
	action_stack_display.queue_free()
