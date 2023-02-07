extends CharacterBody3D

var is_cube_rotating = false
var start
var goal
var t = 0.0

enum {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM,
}

func _physics_process(delta):
	if is_cube_rotating:
		t += delta
		basis = start.slerp(goal, t) 
		if t > 1:
			stop_rotation()


func start_cube_rotation(dir):
	if is_cube_rotating:
		return
	is_cube_rotating = true


	# Step 2: Animate the rotation.
	var axis = -dir.cross(Vector3.DOWN)
	start = basis
	goal = basis.rotated(axis, PI/2)

func stop_rotation():
	is_cube_rotating = false
	t = 0.0