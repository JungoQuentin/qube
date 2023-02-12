extends Node3D
class_name MapCube


@onready var main = get_tree().get_current_scene()

var speed = 1.5
@export var dimension: int = 0
var is_rotating = false
var goal: Basis
var t: float = 0.0
var rotator: Node3D
var rotator_goal: Basis

func _ready():
	set_disable_scale(true)

	if dimension == 0:
		Log.crash("dimension not set !!")
	Global.map_cube = self

func start_cube_rotation(dir):
	is_rotating = true
	rotator = Node3D.new()
	rotator.set_disable_scale(true)
	main.add_child(rotator)
	main.remove_child(Global.player)
	rotator.add_child(Global.player)

	# Step 2: Animate the rotation.
	var axis = dir.cross(Vector3.DOWN)
	goal = basis.rotated(-axis, PI / 2)
	rotator_goal = rotator.basis.rotated(-axis, PI / 2)


	var time = Global.player.speed * 2
	

	var tween = get_tree().create_tween().set_parallel().bind_node(self)
	tween.tween_property(self, "basis:z", goal.z, time)
	tween.tween_property(self, "basis:y", goal.y, time)
	tween.tween_property(self, "basis:x", goal.x, time)
	tween.tween_property(rotator, "basis:z", rotator_goal.z, time)
	tween.tween_property(rotator, "basis:y", rotator_goal.y, time)
	tween.tween_property(rotator, "basis:x", rotator_goal.x, time)
	tween.chain().tween_callback(func():is_rotating = false; stop_rotation())
	#tween.play()

func stop_rotation(reset_player_pivot=true):
	is_rotating = false
	t = 0.0
	rotator.remove_child(Global.player)
	main.add_child(Global.player)
	rotator.queue_free()
	var shift = dimension - 1
	if reset_player_pivot:
		Log.debug("wait reset from map")
		await Utils.wait_while(func(): return Global.player.is_rolling)
		Log.debug("start reset from map")
		Global.player.reset_pivot(-shift * Global.direction)

#####

func reset():
	if is_rotating:
		stop_rotation()
	transform = Transform3D.IDENTITY
