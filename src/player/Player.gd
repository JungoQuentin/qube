extends Node3D 

@export var speed = 5.
@onready var pivot = $Pivot
@onready var mesh: MeshInstance3D = $Pivot/Mesh
@onready var raycast: RayCast3D = $RayCast3D
@onready var original_raycast_pos = raycast.position
var rolling = false
var start
var goal
var t = 0.0
var is_on_edge = false

func _ready():
	Global.player = self

func _input(_event):
	if rolling or Global.cube.is_rotating:
		return
	var forward = Vector3.FORWARD
	if Input.is_action_pressed("top"):
		_roll(forward)
	if Input.is_action_pressed("bottom"):
		_roll(-forward)
	if Input.is_action_pressed("right"):
		_roll(forward.cross(Vector3.UP))
	if Input.is_action_pressed("left"):
		_roll(-forward.cross(Vector3.UP))
	# DEBUG helper
	if Input.is_action_just_pressed("ui_accept"):
		raycast.get_collider().touched()

func _physics_process(delta):
	var material: StandardMaterial3D = mesh.mesh.surface_get_material(0)
	material.albedo_color = Color.from_hsv(190. / 360, 1, 1, Global.fade / 2.4)
	mesh.mesh.surface_set_material(0, material)
	if rolling: # TODO into tween (not currently supported)
		t += delta * (speed / 2 if is_on_edge else speed)
		pivot.basis = start.slerp(goal, t) 
	if t >= 1:
		if not is_on_edge: reset(Global.direction)
		rolling = false

func reset(direction, _from_cube=false):
	t = 0.0
	mesh.transform.origin = Vector3(0, 0.5, 0)
	pivot.transform = Transform3D.IDENTITY
	self.transform.origin += direction

	raycast.force_raycast_update()
	var block = raycast.get_collider()
	if block:
		block.touched()

func _roll(dir):
	if rolling or Global.cube.is_rotating:
		return
	rolling = true
	Global.direction = dir
	_check_edge(dir)
	_offset(dir)
	_set_animation(dir)

func _check_edge(dir):
	raycast.position += dir
	raycast.force_raycast_update()
	is_on_edge = not raycast.is_colliding()
	if is_on_edge:
		Global.cube.start_cube_rotation(dir)
	raycast.position = original_raycast_pos

func _offset(dir):
	pivot.translate(dir / 2)
	mesh.transform.origin -= dir /2

func _set_animation(dir):
	var axis = dir.cross(Vector3.DOWN)
	start = pivot.basis
	goal = pivot.basis.rotated(axis, PI/2)
	if is_on_edge:
		goal = pivot.basis.rotated(-axis, PI * 1.04)