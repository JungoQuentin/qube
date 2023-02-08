extends CharacterBody3D

@export var speed = 5.
@onready var pivot = $Pivot
@onready var mesh: MeshInstance3D = $Pivot/Mesh
@onready var raycast: RayCast3D = $RayCast3D
var rolling = false
var start
var goal
var t = 0.0
var is_on_edge = false

func _ready():
	Global.player = self

func _input(_event):
	var forward = Vector3.FORWARD
	if Input.is_action_pressed("top"):
		roll(forward)
	if Input.is_action_pressed("bottom"):
		roll(-forward)
	if Input.is_action_pressed("right"):
		roll(forward.cross(Vector3.UP))
	if Input.is_action_pressed("left"):
		roll(-forward.cross(Vector3.UP))

func _physics_process(delta):
	var material: StandardMaterial3D = mesh.mesh.surface_get_material(0)
	material.albedo_color = Color.from_hsv(190. / 360, 1, 1, Global.fade / 2.4)
	mesh.mesh.surface_set_material(0, material)


	if rolling:
		t += delta * (speed / 2 if is_on_edge else speed)
		pivot.basis = start.slerp(goal, t) 
	if t > 1:
		rolling = false
		if not is_on_edge: reset(Global.direction)


func roll(dir):
	if rolling or Global.cube.is_rotating:
		return
	rolling = true
	Global.direction = dir

	# Step 0: Check if edge of cube
	raycast.position = dir
	raycast.force_raycast_update()
	is_on_edge = not raycast.is_colliding()

	if is_on_edge:
		print("on edge")
		Global.cube.start_cube_rotation(dir)
	raycast.position = Vector3.ZERO

	# Step 1: Offset the pivot.
	pivot.translate(dir / 2)
	mesh.transform.origin -= dir /2

	# Step 2: Animate the rotation.
	var axis = dir.cross(Vector3.DOWN)
	start = pivot.basis
	goal = pivot.basis.rotated(axis, PI/2)
	if is_on_edge:
		goal = pivot.basis.rotated(-axis, PI * 1.04)

func reset(direction):
	t = 0.0
	mesh.transform.origin = Vector3(0, 0.5, 0)
	pivot.transform = Transform3D.IDENTITY
	self.transform.origin += direction

	raycast.force_raycast_update()
	var block = raycast.get_collider()
	if block:
		block.touched()
		print(block, block.position, self.position)

	#var collision_point = raycast.get_collision_point()
	#var grid_map = Global.cube.grid_map
	#var cell_position = Global.get_cell_position(collision_point)
	#var cell_item = grid_map.get_cell_item(cell_position)
	#grid_map.set_cell_item(cell_position, 1)
	#print(collision_point, cell_position, cell_item)

