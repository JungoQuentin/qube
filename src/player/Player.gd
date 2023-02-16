extends Node3D 

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2
var is_moving = false 
var has_neighbour: bool
var is_on_edge = false
var we_are_on_this_cube_now = null

func _ready():
	Global.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = Colors.player_color
	if Colors.player_fade:
		_start_transparence_animation()
	await _set_start_pos()

func _set_start_pos():
	await Utils.wait_while(func(): return Global.startCube == null)
	position = Global.startCube.global_position + Vector3.UP
	we_are_on_this_cube_now = Global.startCube

func _process(_delta):
	if not is_moving: _get_action_input()
		
func _get_action_input():
	if not Utils.is_one_action_pressed(["top", "bottom", "right", "left"]):
		return
	var direction = Vector3.FORWARD
	if Input.is_action_pressed("bottom"):
		direction = -direction
	elif Input.is_action_pressed("right"):
		direction = direction.cross(Vector3.UP)
	elif Input.is_action_pressed("left"):
		direction = -direction.cross(Vector3.UP)
	
	var move_logic = MoveLogic.new_roll(self, direction)
	if has_neighbour:
		_push_neighbour(move_logic)
	else:
		_roll(direction, move_logic)

#### ROLL LOGIC ####

func _push_neighbour(move_logic):
	move_logic.push_neighbour()

func _roll(direction: Vector3, move_logic):
	if is_on_edge: Global.map_cube.start_cube_rotation(direction)
	await move_logic.roll()
	move_logic.reset_pivot()
	var reset_direction = direction
	if is_on_edge:
		reset_direction = -(Global.map_cube.dimension - 1) * direction
	await move_logic.reset_position(reset_direction)
	is_moving = false

	var block = Utils.get_raycast_collider(self, Vector3.ZERO, Vector3.DOWN)
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != block:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = block
	Actions.add_action(position, Global.map_cube.basis)
	Actions.undo_stack.clear()

#####

# TODO refactor to loop
func _start_transparence_animation():
	var material = mesh_instance.mesh.surface_get_material(0)
	var _tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(material, "albedo_color:a", min_transparency, 2)
	_tween.tween_property(material, "albedo_color:a", max_transparency, 2)
	_tween.tween_callback(_start_transparence_animation)
	_tween.play()

func reset():
	# TODO
	#var move_logic = MoveLogic.new(self)
	#move_logic.reset_pivot(Vector3.ZERO)
	_set_start_pos()
