class_name Player extends Node3D

#region DECLARATION

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _level: Level = get_parent()
@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2
@onready var initial_transform:= global_transform
var is_moving = false 
var we_are_on_this_cube_now: Cube = null
var joystick: Joystick
var move_logic: CubeMoveLogic

#endregion


func _ready():
	joystick = load("res://src/joystick/joystick.tscn").instantiate()
	add_child(joystick)
	_level.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = Colors.player_color
	await _level.level_initialized


func _process(_delta):
	if is_moving or _level.camera.is_moving:
		return
	_get_action_input()


func _get_action_input():
	# TODO check if camera is not on the player
	var input = Utils.is_one_action_pressed(["player_top", "player_bottom", "player_right", "player_left"])
	if input.is_empty():
		input = joystick.get_string_direction()
	if input.is_empty():
		return
	if _level.camera.has_moved_away_from_player():
		await _level.camera.go_to_player()
		return
	var direction: Vector3
	match input:
		"player_bottom":
			direction = Vector3.DOWN
		"player_right":
			direction = Vector3.RIGHT
		"player_left":
			direction = Vector3.LEFT
		"player_top":
			direction = Vector3.UP
	is_moving = true
	var camera_basis = _level.camera.basis
	direction = camera_basis * direction
	var floor_direction = camera_basis * Vector3.FORWARD
	move_logic = CubeMoveLogic.new(self, direction, floor_direction).init_forward_roll()
	_roll()


func _roll():
	if move_logic.is_going_to_hole:
		is_moving = false
		return
	if move_logic._is_going_to_change_face:
		_level.camera.player_move(move_logic._direction, move_logic._floor_direction)
	
	## if we are going to change face, check if we also push a moving cube
	if move_logic.floor_neighbour is MovingCube and not move_logic.floor_neighbour.in_a_hole:
		var neighbour: MovingCube = move_logic.floor_neighbour
		if neighbour.can_push(move_logic._floor_direction, -move_logic._direction):
			neighbour.on_push(move_logic._floor_direction, -move_logic._direction)
		else:
			is_moving = false
			return
	
	if move_logic.floor_goal is IceCube:
		var new_position = move_logic.floor_goal.get_end_slide(move_logic._direction, move_logic._floor_direction)
		Utils.run_after_sleep(0.25, func(): is_moving = false)
		global_position = new_position - move_logic._floor_direction
		return
	
	## if our neighbour is a MovingCube, we try to push him
	var neighbour: Cube = Utils.get_raycast_collider(_level, global_position, move_logic._direction)
	if neighbour != null and neighbour is MovingCube:
		if neighbour.can_push(move_logic._direction, move_logic._floor_direction):
			neighbour.on_push(move_logic._direction, move_logic._floor_direction)
		else:
			is_moving = false
			return
	# TODO -> ActionSystem.add_action()
	
	await move_logic.roll()

	## roll us back if our goal is rejecting
	if move_logic.floor_goal and move_logic.floor_goal.is_rejecting():
		await move_logic.roll_back()
		# TODO ActionSystem.actions.pop_back()
		if we_are_on_this_cube_now is SingleUseCube:
			print("go to infinite recursion")
	#else: # TODO
		#ActionSystem.undo_stack.clear()
	
	## leave old floor and set new
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != move_logic.floor_goal:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = move_logic.floor_goal
	
	move_logic.reset_pivot()
	is_moving = false


func reset():
	abort_move()
	global_position = initial_transform

## Abort the current move and return false if there was no move
func abort_move() -> bool:
	if not is_moving:
		return false
	print("abort move")
	
	# TODO really abort the move !
	move_logic.reset_pivot()
	return true
