class_name BaseLevel extends Node3D

@onready var player: Player = $Player
@onready var map_cube: Node3D = $MapCube
@onready var env_ligth: Node3D = preload("res://src/levels/env/EnvLight.tscn").instantiate()
@onready var action_system:= ActionSystem.new(self)
var input_handler:= InputHandler.new()
var camera_controller: CameraController
var switch_cubes: Array
var single_use_cubes: Array
var moving_cubes: Array
var laser_cubes: Array
var max_plus: Vector3
var max_minus: Vector3


func _ready():
	add_child(camera_controller)
	add_child(env_ligth)
	add_child(input_handler)
	action_system
	_get_max()
	_init_map()
	Save.settings.apply(get_tree())
	
	## dbg
	_init_dbg()
	#_init_player_current_face()
	#_init_action_stack_display()
	_init_locker_display()


## init the map by getting all the special cubes
func _init_map():
	var map_cube_children = map_cube.get_children()
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


func abort_move():
	player.abort_move()


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

var _stack_display_enable:= false
var _locker_display_enable:= false
var _locker_display: VBoxContainer
var _all_debug: HBoxContainer
var _label_current_face:= Label.new()
var _action_stack_display: VBoxContainer


func _process(_delta):
	_label_current_face.text = "current:" + str(object_current_face(player)) + "\nmax:" + str(max_plus) + "\nmin:" + str(max_minus) + "\nplayer_pos" + str(player.global_position)

func _init_dbg():
	_all_debug = HBoxContainer.new()
	add_child(_all_debug)

func _init_player_current_face():
	_all_debug.add_child(_label_current_face)

## only for debug purpose
## will display the stack of the player actions (inputs)
func _init_action_stack_display():
	_stack_display_enable = true
	_action_stack_display = VBoxContainer.new()
	_all_debug.add_child(_action_stack_display)

func update_stack_display():
	if not _stack_display_enable:
		return
	_action_stack_display.get_children().map(func(child): child.queue_free())
	var i = 0
	for action in action_system.state_stack:
		_add_state_to_stack_display(action, i)
		i += 1

func _add_state_to_stack_display(state: LevelState, index: int):
	if not _stack_display_enable:
		return
	var new_label: Label = Label.new()
	new_label.text = str(state)
	_action_stack_display.add_child(new_label)
	if index == action_system.current_state_index:
		new_label.text = new_label.text + " CURRENT "


## only for debug purpose
func _init_locker_display():
	_locker_display_enable = true
	_locker_display = VBoxContainer.new()
	_all_debug.add_child(_locker_display)

func update_locker_display():
	if not _locker_display_enable:
		return
	_locker_display.get_children().map(func(child): child.queue_free())
	var i = 0
	for action in input_handler._action_stack:
		_add_locker_display(action, i)
		i += 1

func _add_locker_display(action: String, _index: int):
	if not _locker_display_enable:
		return
	var new_label: Label = Label.new()
	new_label.text = action
	_locker_display.add_child(new_label)


#endregion
