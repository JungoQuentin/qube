extends Cube

@onready var pivot = $Pivot
@onready var main = get_tree().get_current_scene()

func _ready():
	super._ready()
	cube_type = MOVING
	initial_color = Colors.moving_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color

func on_touch():
	super.on_touch()

func on_leave():
	super.on_leave()

func on_push(direction: Vector3):
	print(self, " pushed")
	#Global.map_cube.find_child("map").remove_child(self)
	#main.add_child(self)
	#await get_tree().process_frame
	
	roll(direction)
	return


#### TODO : facto truc comment avec player
var is_moving = false
var is_on_edge = false
var start: Basis
var goal: Basis

func roll(dir: Vector3, do_add_action=true):
	if is_moving:
		return
	is_moving = true
	if Utils.push_neighbour(self, dir):
		is_moving = false
		return
	Global.direction = dir
	is_on_edge = not Utils.get_raycast_collider(self, dir + Vector3.UP / 2, Vector3.DOWN)
	_offset(dir)
	_animation(dir)

	if do_add_action:
		Actions.add_action(position, Global.map_cube.basis)
		Actions.undo_stack.clear()

func _offset(dir):
	pivot.translate(dir / 2)
	mesh_instance.transform.origin -= dir /2

func _animation(dir):
	var axis = dir.cross(Vector3.DOWN)
	start = pivot.basis
	goal = pivot.basis.rotated(axis, PI/2) if not is_on_edge else pivot.basis.rotated(-axis, PI)
	var b_tween = get_tree().create_tween()
	var speed = Global.player.speed if not is_on_edge else Global.player.speed * 2
	b_tween.tween_method(_tween_basis, 0., 1., speed) 
	await b_tween.finished
	if not is_moving: # modified elsewhere
		return
	if not is_on_edge:
		reset_pivot(dir)
	if is_on_edge:
		var shift = Global.map_cube.dimension - 1
		reset_pivot(-shift * dir)

func _tween_basis(t):
	if not is_moving:
		return
	pivot.basis = start.slerp(goal, t)

func reset_pivot(direction=Vector3.ZERO):
	is_moving = false
	mesh_instance.transform.origin = Vector3(0, 0.5, 0)
	pivot.transform = Transform3D.IDENTITY
	self.transform.origin += direction