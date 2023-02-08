extends Node3D 

@onready var pivot = $Pivot
@onready var mesh: MeshInstance3D = $Pivot/Mesh
@onready var raycast: RayCast3D = $RayCast3D
@onready var original_raycast_pos = raycast.position

@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 5.
@export var color: Color = Color.from_hsv(200, 1, 1, 1):
	set(n):
		if mesh: mesh.mesh.surface_get_material(0).albedo_color = n 
		color = n

var loaded = false
var is_rolling = false 
var start
var goal
var t = 0.0
var is_on_edge = false


func _ready():
	Global.player = self
	mesh.mesh.surface_get_material(0).albedo_color = color
	_start_transparence_animation()
	_set_start_pos()

func _set_start_pos():
	var passed = 0.0
	while Global.startCube == null and passed < 3:
		passed += 0.01
		await get_tree().create_timer(0.01).timeout
	position = Global.startCube.global_position + Vector3.UP / 2


func _physics_process(delta):
	# TODO into tween (not currently supported)
	if is_rolling:
		t += delta * (speed / 2 if is_on_edge else speed)
		pivot.basis = start.slerp(goal, t) 
	if is_rolling and t >= 1:
		if not is_on_edge: reset(Global.direction)
		is_rolling = false

		
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
	# DEBUG helper
	if Input.is_action_just_pressed("ui_accept"):
		raycast.get_collider().touched()

func reset(direction, _from_cube=false):
	t = 0.0
	mesh.transform.origin = Vector3(0, 0.5, 0)
	pivot.transform = Transform3D.IDENTITY
	self.transform.origin += direction

	raycast.force_raycast_update()
	var block = raycast.get_collider()
	if block:
		block.touched()

func roll(dir):
	if is_rolling or Global.map_cube.is_rotating:
		return
	is_rolling = true
	Global.direction = dir
	_check_edge(dir)
	_offset(dir)
	_set_animation(dir)

func _check_edge(dir):
	raycast.position += dir
	raycast.force_raycast_update()
	is_on_edge = not raycast.is_colliding()
	if is_on_edge:
		Global.map_cube.start_cube_rotation(dir)
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

#####

func _start_transparence_animation():
	var material = mesh.mesh.surface_get_material(0)
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(material, "albedo_color:a", min_transparency, 2)
	tween.tween_property(material, "albedo_color:a", max_transparency, 2)
	tween.tween_callback(_start_transparence_animation)
	tween.play()
