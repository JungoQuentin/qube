extends StaticBody3D
class_name Player

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _level: BaseLevel = get_parent()
@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2
@onready var initial_transform:= global_transform
var _is_moving = false 
var we_are_on_this_cube_now: Cube = null
var joystick: Joystick
var move_logic: CubeMoveLogic
signal start_move
signal end_move


func _ready():
	joystick = load("res://src/joystick/joystick.tscn").instantiate()
	add_child(joystick)
	_level.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = _level.color_set.player_color
	await Utils.wait_while(func(): return _level.camera_controller == null)
	var floor_direction = _level.camera_controller.get_camera_basis() * Vector3.FORWARD
	await get_tree().process_frame
	we_are_on_this_cube_now = Utils.get_raycast_collider(_level, global_position, floor_direction)


func handle_input(input: String):
	_is_moving = true
	var direction: Vector3 = {
		"player_bottom": Vector3.DOWN,
		"player_right": Vector3.RIGHT,
		"player_left": Vector3.LEFT,
		"player_top": Vector3.UP,
	}[input]
	var camera_basis = _level.camera_controller.get_camera_basis()
	direction = camera_basis * direction
	var floor_direction = camera_basis * Vector3.FORWARD
	move_logic = CubeMoveLogic.new(self, direction, floor_direction)
	if move_logic.can_roll():
		await _roll()
	else:
		await _cant_roll()
	# TODO check if in a hole / hit by a laser
	_is_moving = false


func _roll():
	## if we are going to change face, check if we also push a moving cube
	if move_logic.floor_neighbour is MovingCube \
		and not move_logic.floor_neighbour.in_a_hole \
		and move_logic.floor_neighbour.can_push(move_logic._floor_direction, -move_logic._direction):
		
		# TODO a ce moment, je n'await pas, je lance un add a InputHandler
		# voir si je creer pas des signaux dans player.handle_input 
		# comme ca je peut creer des callback dans InputHandler
		_level.action_system.player_start_push()
		await move_logic.floor_neighbour.on_push(move_logic._floor_direction, -move_logic._direction)
		_level.action_system.player_end_push()
		return
	
	## if our neighbour is a MovingCube, we try to push him
	var neighbour: Cube = Utils.get_raycast_collider(_level, global_position, move_logic._direction)
	if neighbour is MovingCube and neighbour.can_push(move_logic._direction, move_logic._floor_direction):
		_level.action_system.player_start_push()
		await neighbour.on_push(move_logic._direction, move_logic._floor_direction)
		_level.action_system.player_end_push()
		return
	
	## Order the camera to change face (if still can move)
	if move_logic._is_going_to_change_face:
		_level.camera_controller.player_change_face(move_logic._direction, move_logic._floor_direction)
	
	start_move.emit()
	await move_logic.roll()
	if move_logic.floor_goal == null:
		Utils.crash("floor_goal does not exist")
		return
	move_logic.floor_goal.on_touch()
	end_move.emit()
	
	## leave old floor and set new
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != move_logic.floor_goal:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = move_logic.floor_goal
	
	move_logic.remove_pivot()


func _cant_roll():
	start_move.emit()
	await move_logic.cant_roll()
	move_logic.remove_pivot()
	end_move.emit()

## Abort the current move and return false if there was no move
func abort_move() -> bool:
	if not _is_moving:
		return false
	move_logic.abort()
	_is_moving = false
	return true


func laser_hit():
	print("je suis hit !")
