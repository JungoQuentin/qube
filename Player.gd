extends CharacterBody3D

@onready var pivot = $Pivot
@onready var raycast: RayCast3D = $RayCast3D
@onready var mesh = $Pivot/Mesh
var rolling = false
var g_dir
var start
var goal
var t = 0.0
var speed = 5.
var is_on_edge = false
var axis

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
	if rolling:
		t += delta * (speed / 2.0 if is_on_edge else speed)
		pivot.basis = start.slerp(goal, t) 
		if t > 1:
			_stop_roll()


func roll(dir):
	if rolling:
		return
	rolling = true
	g_dir = dir

	# Step 0: Check if edge of cube
	raycast.position = dir
	raycast.force_raycast_update()
	is_on_edge = not raycast.is_colliding()
	if is_on_edge:
		print("on edge")
		get_parent().start_cube_rotation(dir)
	raycast.position = Vector3.ZERO

	# Step 1: Offset the pivot.
	pivot.translate(dir / 2)
	mesh.translate(-dir / 2)

	# Step 2: Animate the rotation.
	axis = dir.cross(Vector3.DOWN)
	start = pivot.basis
	goal = pivot.basis.rotated(axis, PI/2)
	if is_on_edge:
		goal = pivot.basis.rotated(axis, -PI)

func _stop_roll():
	t = 0.0
	rolling = false
	mesh.transform.origin = Vector3(0, 0.5, 0)
	pivot.transform = Transform3D.IDENTITY
	transform.origin += g_dir

	if is_on_edge:
		transform.origin += Vector3.DOWN
