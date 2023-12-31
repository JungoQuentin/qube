class_name Player extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _level: Level = get_parent()
@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2
@onready var initial_transform:= global_transform
var is_moving = false 
var we_are_on_this_cube_now: Cube = null
#var joystick: Joystick
var move_logic: CubeMoveLogic


func _ready():
	#joystick = load("res://src/joystick/joystick.tscn").instantiate()
	#add_child(joystick)
	_level.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = Colors.player_color
	await Utils.wait_while(func(): return _level.camera == null)
	var floor_direction = _level.camera.basis * Vector3.FORWARD
	we_are_on_this_cube_now = Utils.get_raycast_collider(_level, global_position, floor_direction)


func _process(_delta):
	if is_moving or _level.camera.is_moving:
		return
	_get_action_input()


func _get_action_input():
	# TODO check if camera is not on the player
	var input = Utils.is_one_action_pressed(["player_top", "player_bottom", "player_right", "player_left"])
	#if input.is_empty():
		#input = joystick.get_string_direction()
	if input.is_empty():
		return
	if not _level.camera.is_front_player():
		await _level.camera.go_to_player()
		return
	is_moving = true
	var direction: Vector3 = {
		"player_bottom": Vector3.DOWN,
		"player_right": Vector3.RIGHT,
		"player_left": Vector3.LEFT,
		"player_top": Vector3.UP,
	}[input]
	var camera_basis = _level.camera.basis
	direction = camera_basis * direction
	var floor_direction = camera_basis * Vector3.FORWARD
	move_logic = CubeMoveLogic.new(self, direction, floor_direction)
	if move_logic.can_roll():
		await _roll()
	else:
		await _cant_roll()
	is_moving = false
	move_logic.queue_free()


func _roll():
	if move_logic._is_going_to_change_face:
		_level.camera.player_move(move_logic._direction, move_logic._floor_direction)
	
	## if we are going to change face, check if we also push a moving cube
	if move_logic.floor_neighbour is MovingCube and not move_logic.floor_neighbour.in_a_hole and move_logic.floor_neighbour.can_push(move_logic._floor_direction, -move_logic._direction):
		move_logic.floor_neighbour.on_push(move_logic._floor_direction, -move_logic._direction)
	
	## if our neighbour is a MovingCube, we try to push him
	var neighbour: Cube = Utils.get_raycast_collider(_level, global_position, move_logic._direction)
	if neighbour is MovingCube and neighbour.can_push(move_logic._direction, move_logic._floor_direction):
		neighbour.on_push(move_logic._direction, move_logic._floor_direction)
	
	ActionSystem.player_start_move()
	_level.player_move(move_logic._direction)
	await move_logic.roll()
	move_logic.floor_goal.on_touch()
	ActionSystem.player_end_move()
	
	## leave old floor and set new
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != move_logic.floor_goal:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = move_logic.floor_goal
	
	move_logic.remove_pivot()


func _cant_roll():
	ActionSystem.player_start_move()
	_level.player_move(move_logic._direction)
	await move_logic.cant_roll()
	move_logic.remove_pivot()
	ActionSystem.player_end_move()

## Abort the current move and return false if there was no move
func abort_move() -> bool:
	if not is_moving:
		return false
	move_logic.abort()
	is_moving = false
	return true
