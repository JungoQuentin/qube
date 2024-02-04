extends StaticBody3D
class_name Player

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var _level: Level = get_parent()
@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2
@onready var initial_transform:= global_transform
var _is_moving = false 
var we_are_on_this_cube_now: Cube = null
var joystick: Joystick
var move_logic: CubeMoveLogic


func _ready():
	joystick = load("res://src/joystick/joystick.tscn").instantiate()
	add_child(joystick)
	_level.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = Colors.player_color
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
	_is_moving = false


func _roll():
	if move_logic._is_going_to_change_face:
		_level.camera_controller.player_change_face(move_logic._direction, move_logic._floor_direction)
	
	## if we are going to change face, check if we also push a moving cube
	if move_logic.floor_neighbour is MovingCube and not move_logic.floor_neighbour.in_a_hole and move_logic.floor_neighbour.can_push(move_logic._floor_direction, -move_logic._direction):
		await move_logic.floor_neighbour.on_push(move_logic._floor_direction, -move_logic._direction)
	
	## if our neighbour is a MovingCube, we try to push him
	var neighbour: Cube = Utils.get_raycast_collider(_level, global_position, move_logic._direction)
	if neighbour is MovingCube and neighbour.can_push(move_logic._direction, move_logic._floor_direction):
		await neighbour.on_push(move_logic._direction, move_logic._floor_direction)
	
	ActionSystem.player_start_move()
	_level.player_start_move(move_logic._direction)
	await move_logic.roll()
	move_logic.floor_goal.on_touch()
	_level.player_end_move()
	ActionSystem.player_end_move()
	
	## leave old floor and set new
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != move_logic.floor_goal:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = move_logic.floor_goal
	
	move_logic.remove_pivot()
	
	## abort if the laser is touching us !
	if _level.is_player_hit_by_laser():
		# TODO this allow redo... (find a better way)
		await ActionSystem._undo()


func _cant_roll():
	ActionSystem.player_start_move()
	#_level.player_start_move(move_logic._direction)
	await move_logic.cant_roll()
	move_logic.remove_pivot()
	#_level.player_end_move()
	ActionSystem.player_end_move()

## Abort the current move and return false if there was no move
func abort_move() -> bool:
	if not _is_moving:
		return false
	move_logic.abort()
	_is_moving = false
	return true


func laser_hit():
	print("je suis hit !")
