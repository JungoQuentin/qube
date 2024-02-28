class_name Level extends Node3D

#region DECLARATION

enum { INGAME, PAUSE, MENU }
var game_state = INGAME
@export var is_level_gate:= false
@export var _camera_mode:= CameraController.CameraMode.NATURAL
@export var _camera_distance:= 18.5
@onready var camera_controller:= CameraController.new(self, _camera_mode, _camera_distance)
@onready var player: Player = $Player
@onready var map_cube: Node3D = $MapCube
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
	add_child(camera_controller)
	add_child(env_ligth)
	_init_dbg()
	#_init_player_current_face()
	#_init_action_stack_display()
	_init_locker_display()
	_get_max()
	ActionSystem.start_level(self)
	InputHandler._level = self
	#if is_level_gate:
		#return
	_init_map()
	update_can_win()
	
	Save.settings.apply(get_tree())
	
	if is_level_gate:
		if LevelManager.get_current_progression().global_position_entry_point.is_equal_approx(Transform3D.IDENTITY):
			LevelManager.get_current_progression().global_position_entry_point = player.global_transform
		else:
			player.global_transform = LevelManager.get_current_progression().global_position_entry_point
		camera_controller.player_want_to_move()

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


func player_start_move(_direction: Vector3):
	if is_level_gate:
		LevelManager.get_current_progression().global_position_entry_point = player.global_transform
		Save.save()
	laser_cubes.map(func(c): c.player_start_move())
	update_can_win()


func player_end_move():
	# TODO should not be called after a scene change !
	laser_cubes.map(func(c): c.player_end_move())
	update_can_win()


func update_can_win():
	if end_cube:
		end_cube.can_win = single_use_cubes.all(func(cube): return cube.is_used)


func is_player_hit_by_laser():
	return laser_cubes.any(func(l: LaserCube): return l.is_collinding_with(player))

## Return the directional vector from the center to the face where the object is 
func object_current_face(object: Node3D) -> Vector3:
	if max_plus.x < snappedf(object.global_position.x, 0.5):
		return Vector3.RIGHT
	if max_plus.y < snappedf(object.global_position.y, 0.5):
		return Vector3.UP
	if max_plus.z < snappedf(object.global_position.z, 0.5):
		return Vector3.BACK
	if max_minus.x > snappedf(object.global_position.x, 0.5):
		return Vector3.LEFT
	if max_minus.y > snappedf(object.global_position.y, 0.5):
		return Vector3.DOWN
	if max_minus.z > snappedf(object.global_position.z, 0.5):
		return Vector3.FORWARD
	return Vector3.ZERO

#region Debug

func _process(_delta):
	label_current_face.text = "current:" + str(object_current_face(player)) + "\nmax:" + str(max_plus) + "\nmin:" + str(max_minus) + "\nplayer_pos" + str(player.global_position)

var all_debug: HBoxContainer
func _init_dbg():
	all_debug = HBoxContainer.new()
	add_child(all_debug)

var label_current_face:= Label.new()
func _init_player_current_face():
	all_debug.add_child(label_current_face)

var action_stack_display: VBoxContainer
## only for debug purpose
## will display the stack of the player actions (inputs)
func _init_action_stack_display():
	_stack_display_enable = true
	action_stack_display = VBoxContainer.new()
	all_debug.add_child(action_stack_display)

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
	all_debug.add_child(locker_display)

func update_locker_display():
	if not _locker_display_enable:
		return
	locker_display.get_children().map(func(child): child.queue_free())
	var i = 0
	for action in InputHandler._locker:
		_add_locker_display(action, i)
		i += 1

func _add_locker_display(action: String, _index: int):
	if not _locker_display_enable:
		return
	var new_label: Label = Label.new()
	new_label.text = action
	locker_display.add_child(new_label)


#endregion
