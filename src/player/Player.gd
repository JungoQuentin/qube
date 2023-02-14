extends Node3D 

@onready var mesh_instance: MeshInstance3D = $Mesh

@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2 #* 10

var loaded = false

var is_moving = false 

var is_pushing: bool
var start: Basis
var goal: Basis
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
		
func _input(_event):
	if is_moving or Global.map_cube.is_rotating:
		return
	var forward = Vector3.FORWARD
	if Input.is_action_pressed("top"):
		roll(forward)
	if Input.is_action_pressed("bottom"):
		roll(-forward)
	if Input.is_action_pressed("right"):
		roll(forward.cross(Vector3.UP))
	if Input.is_action_pressed("left"):
		roll(-forward.cross(Vector3.UP))

#### ROLL LOGIC ####

func roll(direction: Vector3, do_add_action=true):
	var move_logic = MoveLogic.new(self)
	move_logic.roll(direction)
	if is_on_edge:
		Global.map_cube.start_cube_rotation(direction)
	
	await move_logic.end_reset
	print("after end reset")

	var block = Utils.get_raycast_collider(self, Vector3.ZERO, Vector3.DOWN)
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != block:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = block

	if do_add_action:
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
	var move_logic = MoveLogic.new(self)
	move_logic.reset_pivot(Vector3.ZERO)
	_set_start_pos()
