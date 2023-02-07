extends CharacterBody3D

@export var speed = 1.5
var is_rotating = false
var start
var goal
var t = 0.0

var rotator: Node3D
var rotator_start
var rotator_goal


func _ready():
	Global.cube = self

func _physics_process(delta):
	if is_rotating:
		t += delta * speed
		basis = start.slerp(goal, t) 
		rotator.basis = rotator_start.slerp(rotator_goal, t)
		if t > 1:
			stop_rotation()

func start_cube_rotation(dir):
	if is_rotating:
		return
	is_rotating = true

	# Step 1: Take player in the rotator node
	rotator = Node3D.new()
	Global.main.add_child(rotator)
	Global.main.remove_child(Global.player)
	rotator.add_child(Global.player)

	# Step 2: Animate the rotation.
	var axis = dir.cross(Vector3.DOWN)
	start = basis
	goal = basis.rotated(-axis, PI / 2)
	rotator_start = rotator.basis
	rotator_goal = rotator.basis.rotated(-axis, PI / 2)


func stop_rotation():
	is_rotating = false
	t = 0.0

	# reset child
	Global.player.transform.origin -= Global.direction * 2
	Global.player.reset()
	rotator.remove_child(Global.player)
	Global.main.add_child(Global.player)
	rotator.queue_free()