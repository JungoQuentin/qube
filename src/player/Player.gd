extends Node3D 

@onready var pivot = $Pivot
@onready var mesh_instance: MeshInstance3D = $Pivot/Mesh

@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2 #* 10

var loaded = false
var is_rolling = false 
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
	if is_rolling or Global.map_cube.is_rotating:
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

func roll(dir: Vector3, do_add_action=true):




	#TODO is working
	if is_rolling or Global.map_cube.is_rotating:
		return
	is_rolling = true
	is_pushing = Utils.push_neighbour(self, dir)
	Global.direction = dir
	_check_edge(dir)
	_offset(dir)
	_animation(dir)

	if do_add_action:
		Actions.add_action(position, Global.map_cube.basis)
		Actions.undo_stack.clear()


func _check_edge(dir):
	var collider = Utils.get_raycast_collider(self, dir, Vector3.DOWN)
	is_on_edge = !collider
	if is_on_edge:
		Global.map_cube.start_cube_rotation(dir)

func _offset(direction):
	pivot.position += direction / 2 + Vector3.DOWN / 2
	mesh_instance.position -= direction / 2 + Vector3.DOWN / 2

func _animation(dir):
	var axis = dir.cross(Vector3.DOWN)
	start = pivot.basis
	goal = pivot.basis.rotated(axis, PI/2) if not is_on_edge else pivot.basis.rotated(-axis, PI)

	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT_IN)
	if is_pushing:
		tween.tween_method(_tween_basis, 0., 0.1, speed / 2) 
		tween.tween_method(_tween_basis, 0.1, 0., speed / 2) 
	else:
		tween.tween_method(_tween_basis, 0., 1., speed if not is_on_edge else speed * 2) 
	await tween.finished
	if not is_rolling: # modified elsewhere
		return
	if not is_on_edge:
		reset_pivot(dir)
	if is_on_edge:
		var shift = Global.map_cube.dimension - 1
		reset_pivot(-shift * dir)

func _tween_basis(t):
	if not is_rolling:
		return
	pivot.basis = start.slerp(goal, t)

func reset_pivot(direction: Vector3):
	is_rolling = false
	mesh_instance.position = Vector3.ZERO
	pivot.transform = Transform3D.IDENTITY
	if not is_pushing:
		position += direction

	var block = Utils.get_raycast_collider(self, Vector3.ZERO, Vector3.DOWN)
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != block:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = block
	if block:
		block.on_touch()

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
	reset_pivot(Vector3.ZERO)
	_set_start_pos()
