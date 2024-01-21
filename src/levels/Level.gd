class_name Level extends Node3D

#region DECLARATION

static var CAMERA_DISTANCE = 18.5
static var CAMERA_FOV = 30.

enum { INGAME, PAUSE, MENU }
enum CameraMode { NATURAL, FIXED }
var game_state = INGAME
@export var is_level_gate:= false
@export var camera_mode:= CameraMode.NATURAL

@onready var player: Player = $Player
@onready var map_cube: Node3D = $MapCube
@onready var in_game_menu: Control = preload("res://src/menu/InGameMenu.tscn").instantiate()
var camera:= FixedCamera.new()
var style_camera = null
var sub_viewport_container = SubViewportContainer.new()
var sub_viewport = SubViewport.new()
@onready var env_ligth: Node3D = preload("res://src/levels/env/EnvLight.tscn").instantiate()
var switch_cubes: Array
var single_use_cubes: Array
var moving_cubes: Array
var laser_cubes: Array
var end_cube: EndCube
var max_plus: Vector3
var max_minus: Vector3
var _stack_display_enable:= false
var _locker_display_enable:= false

#endregion


func _ready():
	add_child(in_game_menu)
	add_child(env_ligth)
	#_init_action_stack_display()
	_init_locker_display()
	_get_max()
	ActionSystem.start_level(self)
	_init_camera()
	if is_level_gate:
		return
	_init_map()
	update_can_win()
	InputHandler._level = self


func _init_camera():
	## init cameras
	#add_child(sub_viewport_container)
	#sub_viewport_container.add_child(sub_viewport)
	#sub_viewport.add_child(camera)
	add_child(camera)
	camera.make_current()
	match camera_mode:
		CameraMode.FIXED:
			pass
		CameraMode.NATURAL:
			style_camera = NaturalCamera.new()
			add_child(style_camera)
			style_camera.make_current()

## 
func player_can_move_camera() -> bool:
	match camera_mode:
		CameraMode.FIXED:
			if not camera.is_front_player():
				return false
		CameraMode.NATURAL:
			if not style_camera.current:
				return false
	return true

func abort_move():
	player.abort_move()

## init the map by getting all the special cubes
func _init_map():
	var map_cube_children = map_cube.get_children()
	var end_cubes = map_cube_children.filter(func(cube): return cube is EndCube)
	if end_cubes.size() != 1:
		OS.alert("Il ne doit y avoir qu'un fin !", "oups")
		Utils.crash(["Il ne doit y avoir qu'un fin !"])
		return
	end_cube = end_cubes[0]
	switch_cubes = map_cube_children.filter(func(cube): return cube is SwitchCube)
	single_use_cubes = map_cube_children.filter(func(cube): return cube is SingleUseCube)
	moving_cubes = map_cube_children.filter(func(cube): return cube is MovingCube) # will also take LaserCube 
	laser_cubes = map_cube_children.filter(func(cube): return cube is LaserCube)
	moving_cubes.map(func(cube): Utils.switch_parent(cube, get_tree().get_current_scene()))

## set max_plus and max_minus. This are vector3 that get the far away position from center, to get face
func _get_max():
	max_plus = Vector3.ZERO
	max_minus = Vector3.ZERO
	for cube in map_cube.get_children():
		if not cube.is_floor():
			continue
		var pos = cube.global_position
		max_plus.x = max(max_plus.x, pos.x)
		max_plus.y = max(max_plus.y, pos.y)
		max_plus.z = max(max_plus.z, pos.z)
		max_minus.x = min(max_minus.x, pos.x)
		max_minus.y = min(max_minus.y, pos.y)
		max_minus.z = min(max_minus.z, pos.z)


#func a_switch_cube_change_state():
	#_update_can_win()


func player_start_move(direction: Vector3):
	laser_cubes.map(func(c): c.player_start_move())
	update_can_win()


func player_end_move():
	laser_cubes.map(func(c): c.player_end_move())
	update_can_win()


func update_can_win():
	if end_cube:
		end_cube.can_win = single_use_cubes.all(func(cube): return cube.is_used)


func is_player_hit_by_laser():
	return laser_cubes.any(func(l: LaserCube): return l.is_collinding_with(player))


func object_current_face(object: Node3D) -> Vector3:
	if max_plus.x < object.global_position.x:
		return Vector3.RIGHT
	if max_plus.y < object.global_position.y:
		return Vector3.UP
	if max_plus.z < object.global_position.z:
		return Vector3.BACK
	if max_minus.x > object.global_position.x:
		return Vector3.LEFT
	if max_minus.y > object.global_position.y:
		return Vector3.DOWN
	if max_minus.z > object.global_position.z:
		return Vector3.FORWARD
	return Vector3.ZERO

#region Debug

var action_stack_display: VBoxContainer
## only for debug purpose
## will display the stack of the player actions (inputs)
func _init_action_stack_display():
	_stack_display_enable = true
	action_stack_display = VBoxContainer.new()
	add_child(action_stack_display)

func update_stack_display():
	if not _stack_display_enable:
		return
	action_stack_display.get_children().map(func(child): child.queue_free())
	var i = 0
	for action in ActionSystem.state_stack:
		_add_state_to_stack_display(action, i)
		i += 1

func _add_state_to_stack_display(state: LevelState, index: int):
	if not _stack_display_enable:
		return
	var new_label: Label = Label.new()
	new_label.text = str(state)
	action_stack_display.add_child(new_label)
	if index == ActionSystem.current_state_index:
		new_label.text = new_label.text + " CURRENT "


var locker_display: VBoxContainer
## only for debug purpose
func _init_locker_display():
	_locker_display_enable = true
	locker_display = VBoxContainer.new()
	add_child(locker_display)

func update_locker_display():
	if not _locker_display_enable:
		return
	locker_display.get_children().map(func(child): child.queue_free())
	var i = 0
	for action in InputHandler._locker:
		_add_locker_display(action, i)
		i += 1

func _add_locker_display(action: String, index: int):
	if not _locker_display_enable:
		return
	var new_label: Label = Label.new()
	new_label.text = action
	locker_display.add_child(new_label)


#endregion
