extends Node3D
class_name Player

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2
var is_moving = false 
var is_on_edge = false
var we_are_on_this_cube_now = null
var joystick: Joystick
var move_logic: CubeMoveLogic
signal end_roll

func _ready():
	joystick = load("res://src/joystick/joystick.tscn").instantiate()
	add_child(joystick)
	Level.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = Colors.player_color
	# if Colors.player_fade:
	# 	_start_transparence_animation()
	await Level.level_initialized
	_set_start_pos()

func _process(_delta):
	if not is_moving:
		_get_action_input()

func _get_action_input():
	var input = Utils.is_one_action_pressed(["top", "bottom", "right", "left"])
	if input.is_empty():
		input = joystick.get_string_direction()
	if input.is_empty():
		return
	var direction = Vector3.FORWARD
	match input:
		"bottom":
			direction = -direction
		"right":
			direction = direction.cross(Vector3.UP)
		"left":
			direction = -direction.cross(Vector3.UP)
	move_logic = CubeMoveLogic.new(self, direction).init_forward_roll()
	if move_logic.has_neighbour:
		_push_neighbour()
		ActionSystem.add_action(Action.Type.PUSH)
	else:
		_roll(direction)
		ActionSystem.add_action()
	if not move_logic._is_on_edge and move_logic.floor_goal.is_blocking():
		ActionSystem.actions.pop_back()
		if we_are_on_this_cube_now is SingleUseCube:
			print("go to infinite recursion")
	else:
		ActionSystem.undo_stack.clear()

## Called another entity to make us roll
func order_roll(direction, _ordering_entity: Node3D = null):
	move_logic = CubeMoveLogic.new(self, direction).init_forward_roll()
	_roll(direction)

#### ROLL LOGIC ####

func _push_neighbour():
	await move_logic.push_neighbour()
	end_roll.emit()
	if await move_logic.neighbour.end_roll:
		await move_logic.neighbour.end_roll
	is_moving = false

func _roll(direction: Vector3):
	if is_on_edge:
		Level.map_cube.start_cube_rotation(direction)
	await move_logic.roll()
	if not is_moving:
		end_roll.emit()
		return
	move_logic.reset_pivot()
	var reset_direction = direction
	if is_on_edge:
		reset_direction = -(Level.map_cube.dimension - 1) * direction
	await move_logic.reset_position(reset_direction)

	## end_roll
	var block = Utils.get_raycast_collider(self, Vector3.ZERO, Vector3.DOWN)
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != block:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = block
	end_roll.emit()

#####

# TODO refactor to loop
# func _start_transparence_animation():
# 	var material = mesh_instance.mesh.surface_get_material(0)
# 	var _tween = create_tween().set_ease(Tween.EASE_IN_OUT)
# 	_tween.tween_property(material, "albedo_color:a", min_transparency, 2)
# 	_tween.tween_property(material, "albedo_color:a", max_transparency, 2)
# 	_tween.tween_callback(_start_transparence_animation)
# 	_tween.play()

func _set_start_pos():
	position = Level.startCube.global_position + Vector3.UP
	we_are_on_this_cube_now = Level.startCube

func reset():
	abort_move()
	_set_start_pos()

## Abort the current move and return false if there was no move
func abort_move() -> bool:
	if not is_moving:
		return false
	move_logic.reset_pivot()
	await move_logic.reset_position(Vector3.ZERO)
	return true
