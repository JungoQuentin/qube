extends Node3D
class_name MapCube


@onready var main = get_tree().get_current_scene()

var speed = 1.5
@export var dimension: int = 0
var is_rotating = false
var goal: Basis
var start: Basis
var rotator: Node3D
var rotator_start: Basis
var rotator_goal: Basis

func _ready():
	if dimension == 0:
		Log.crash("dimension not set !!")
	Global.map_cube = self

func start_cube_rotation(dir):
	is_rotating = true
	rotator = Node3D.new()
	main.add_child(rotator)
	main.remove_child(Global.player)
	rotator.add_child(Global.player)

	# Step 2: Animate the rotation.
	var axis = dir.cross(Vector3.DOWN)
	start = basis
	rotator_start = rotator.basis
	goal = basis.rotated(-axis, PI / 2)
	rotator_goal = rotator.basis.rotated(-axis, PI / 2)

	var tween = get_tree().create_tween()
	tween.tween_method(_tween_basis, 0., 1., Global.player.speed * 2)
	await tween.finished
	if not is_rotating: # chandeg elsewhere !
		return
	is_rotating = false
	stop_rotation()

func _tween_basis(t):
	if not is_rotating: # chandeg elsewhere !
		return
	basis = start.slerp(goal, t)
	rotator.basis = rotator_start.slerp(rotator_goal, t)

func stop_rotation():
	basis = goal
	rotator.remove_child(Global.player)
	main.add_child(Global.player)
	rotator.queue_free()
	is_rotating = false

func reset():
	if is_rotating:
		stop_rotation()
	transform = Transform3D.IDENTITY
