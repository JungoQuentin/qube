class_name Player extends Node3D

#region DECLARATION

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _level = get_parent()
@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2
var is_moving = false 
var we_are_on_this_cube_now: Cube = null
var joystick: Joystick
var move_logic: CubeMoveLogic
signal end_roll

#endregion


func _ready():
	joystick = load("res://src/joystick/joystick.tscn").instantiate()
	add_child(joystick)
	_level.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = Colors.player_color
	await _level.level_initialized
	_set_start_pos()


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
	
	if move_logic.has_neighbour:
		# TODO ce sera la meme action, vu que ca va se faire d'un coup
		#_push_neighbour()
		ActionSystem.add_action(Action.Type.PUSH)
	else:
		_roll(direction)
		ActionSystem.add_action()


func _roll(direction: Vector3):
	if move_logic._is_going_to_change_face:
		_level.camera.player_move(move_logic._direction, move_logic._floor_direction)
	await move_logic.roll()
	if not is_moving: # TODO
		end_roll.emit()
		return
	if move_logic.floor_goal and move_logic.floor_goal.is_rejecting():
		await move_logic.roll_back()
		ActionSystem.actions.pop_back()
		if we_are_on_this_cube_now is SingleUseCube:
			print("go to infinite recursion")
	else:
		ActionSystem.undo_stack.clear()
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != move_logic.floor_goal:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = move_logic.floor_goal
	move_logic.reset_pivot()
	end_roll.emit()
	is_moving = false


func _set_start_pos():
	position = _level.startCube.global_position + Vector3.BACK
	we_are_on_this_cube_now = _level.startCube

func reset():
	abort_move()
	_set_start_pos()

## Abort the current move and return false if there was no move
func abort_move() -> bool:
	if not is_moving:
		return false
	move_logic.reset_pivot()
	return true
