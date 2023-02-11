extends Node3D
class_name MapCube


@onready var main = get_tree().get_current_scene()

var speed = 1.5
@export var dimension: int = 0
var is_rotating = false
var start: Basis
var goal: Basis
var t: float = 0.0
var rotator: Node3D
var rotator_start: Basis
var rotator_goal: Basis

func _ready():
	if dimension == 0:
		Log.crash("dimension not set !!")
	Global.map_cube = self

# TODO remplacer cela par un Tween ! (pour l'instant ca ne marche pas avec Basis)
# Ca permettra de definir une vitesse fixe de transition en temps, pour avoir la meme qu'avec le player !
func _physics_process(delta):
	if is_rotating:
		t += delta * speed
		basis = start.slerp(goal, t) 
		rotator.basis = rotator_start.slerp(rotator_goal, t)
	if t >= 1:
		stop_rotation()

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

func stop_rotation():
	is_rotating = false
	t = 0.0
	rotator.remove_child(Global.player)
	main.add_child(Global.player)
	rotator.queue_free()
	var shift = dimension - 1
	Global.player.reset_pivot(-shift * Global.direction)

#####

func reset():
	if is_rotating:
		stop_rotation()
	transform = Transform3D.IDENTITY
