class_name Level extends Node3D

#region DECLARATION

enum { INGAME, PAUSE, MENU }
var game_state = INGAME
@onready var player: Player = $Player
@onready var map_cube: Node3D = $MapCube
@onready var in_game_menu: Control = preload("res://src/menu/InGameMenu.tscn").instantiate()
@onready var camera: MyCamera = preload("res://src/levels/env/Camera.tscn").instantiate()
@onready var env_ligth: Node3D = preload("res://src/levels/env/EnvLight.tscn").instantiate()
var switch_cubes: Array
var single_use_cubes: Array
var moving_cubes: Array
var living_cubes: Array
var end_cube: EndCube

#endregion


func _ready():
	add_child(in_game_menu)
	add_child(camera)
	add_child(env_ligth)
	_init_action_stack_display()
	_init_map()
	_update_can_win()
	ActionSystem.start_level(self)


func abort_move():
	await player.abort_move()

## init the map by getting all the special cubes
func _init_map():
	var map_cube_children = map_cube.get_children()
	var end_cubes = map_cube_children.filter(func(cube): return cube is EndCube)
	if end_cubes.size() != 1:
		printerr("Il ne doit y avoir qu'un fin !")
		OS.alert("Il ne doit y avoir qu'un fin !", "oups")
		get_tree().quit()
		return
	end_cube = end_cubes[0]
	living_cubes = map_cube_children.filter(func(cube): return cube is LivingCube)
	switch_cubes = map_cube_children.filter(func(cube): return cube is SwitchCube)
	single_use_cubes = map_cube_children.filter(func(cube): return cube is SingleUseCube)
	moving_cubes = map_cube_children.filter(func(cube): return cube is MovingCube)
	moving_cubes.map(func(cube): Utils.switch_parent(cube, get_tree().get_current_scene()))


func a_switch_cube_change_state():
	_update_can_win()


func player_move(direction: Vector3):
	living_cubes.map(func(l_cube): l_cube.player_move(direction))


func _update_can_win():
	var all_switch_on = switch_cubes.all(func(cube): return cube.on)
	var can_win = all_switch_on
	end_cube.can_win = can_win


#region Debug

var action_stack_display: VBoxContainer
## only for debug purpose
## will display the stack of the player actions (inputs)
func _init_action_stack_display():
	action_stack_display = VBoxContainer.new()
	add_child(action_stack_display)

func update_stack_display():
	action_stack_display.get_children().map(func(child): child.queue_free())
	var i = 0
	for action in ActionSystem.state_stack:
		_add_state_to_stack_display(action, i)
		i += 1

func _add_state_to_stack_display(state: LevelState, index: int):
	var new_label: Label = Label.new()
	new_label.text = str(state)
	action_stack_display.add_child(new_label)
	if index == ActionSystem.current_state_index:
		new_label.text = new_label.text + " CURRENT "
	#elif index > ActionSystem.current_state_index:
		#new_label.add_theme_color_override("color", Color.BLACK)

#endregion
