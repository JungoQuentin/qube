extends Node3D
class_name MapCube


@onready var main = get_tree().get_current_scene()
@onready var cubes = find_child("map")

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

func start_cube_rotation(direction: Vector3):
	is_rotating = true
	rotator = Node3D.new()
	main.add_child(rotator)
	Utils.switch_parent(Global.player, rotator)

	# TODO : tout le moving cube rotate sur eu meme dans la meme direction
	#Global.moving_cubes.map(func(cube): cube.map_rot(direction))
	Global.moving_cubes.map(func(cube): Utils.switch_parent(cube, rotator, true))

	# Animate the rotation.
	var axis = direction.cross(Vector3.DOWN)
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

signal end_rotation
func stop_rotation():
	basis = goal
	Utils.switch_parent(Global.player, main)
	Global.moving_cubes.map(func(cube): Utils.switch_parent(cube, main, true); cube.map_rot(Global.direction))
	rotator.queue_free()
	is_rotating = false
	end_rotation.emit()


func reset():
	if is_rotating:
		stop_rotation()
	transform = Transform3D.IDENTITY
