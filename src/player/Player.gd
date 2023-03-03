extends Node3D 

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2
var is_moving = false 
var is_on_edge = false
var we_are_on_this_cube_now = null
var joystick: Joystick
signal end_roll

func _ready():
	joystick = load("res://src/joystick/joystick.tscn").instantiate()
	add_child(joystick)
	Global.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = Colors.player_color
	if Colors.player_fade:
		_start_transparence_animation()
	await Global.level_initialized
	_set_start_pos()

func _process(_delta):
	if not is_moving:
		_get_action_input()

func _get_action_input():
	var input = Utils.is_one_action_pressed(["top", "bottom", "right", "left"])
	if input.is_empty():
		input = joystick.get_string_direction()
	var direction = Vector3.FORWARD
	match input:
		"bottom":
			direction = -direction
		"right":
			direction = direction.cross(Vector3.UP)
		"left":
			direction = -direction.cross(Vector3.UP)
		"":
			return
	Actions.undo_stack.clear()
	
	var move_logic: MoveLogic = MoveLogic.new(self, direction).init_forward_roll()
	if move_logic.has_neighbour:
		_push_neighbour(move_logic)
		Actions.add_action(ActionNode.Type.PUSH)
	else:
		_roll(direction, move_logic)
		Actions.add_action()

	if not move_logic._is_on_edge and move_logic.floor_goal.is_blocking():
		Actions.actions.pop_back()
		print("will be reject")
		if we_are_on_this_cube_now is SingleUseCube:
			print("go to infinite recursion")

## Called another entity to make us roll
func order_roll(direction, _ordering_entity: Node3D = null):
	var move_logic = MoveLogic.new(self, direction).init_forward_roll()
	_roll(direction, move_logic)

#### ROLL LOGIC ####

func _push_neighbour(move_logic):
	await move_logic.push_neighbour()
	end_roll.emit()
	if await move_logic.neighbour.end_roll:
		await move_logic.neighbour.end_roll
	is_moving = false

func _roll(direction: Vector3, move_logic):
	if is_on_edge: Global.map_cube.start_cube_rotation(direction)
	await move_logic.offset().roll()
	move_logic.reset_pivot()
	var reset_direction = direction
	if is_on_edge:
		reset_direction = -(Global.map_cube.dimension - 1) * direction
	await move_logic.reset_position(reset_direction)

	## end_roll
	var block = Utils.get_raycast_collider(self, Vector3.ZERO, Vector3.DOWN)
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != block:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = block
	is_moving = false
	end_roll.emit()

#####

# TODO refactor to loop
func _start_transparence_animation():
	var material = mesh_instance.mesh.surface_get_material(0)
	var _tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(material, "albedo_color:a", min_transparency, 2)
	_tween.tween_property(material, "albedo_color:a", max_transparency, 2)
	_tween.tween_callback(_start_transparence_animation)
	_tween.play()

func _set_start_pos():
	position = Global.startCube.global_position + Vector3.UP
	we_are_on_this_cube_now = Global.startCube

func reset():
	# TODO
	#var move_logic = MoveLogic.new(self)
	#move_logic.reset_pivot(Vector3.ZERO)
	_set_start_pos()

func abort_moving():
	pass
