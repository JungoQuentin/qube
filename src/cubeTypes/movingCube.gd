extends Cube

@onready var pivot = self.find_child("Pivot")
@onready var main = get_tree().get_current_scene()

func _ready():
	super._ready()

	# TODO refacto auto => detecter le type de cube et lui appliquer la couleur, ...
	cube_type = MOVING
	initial_color = Colors.moving_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color

func on_push(direction: Vector3):
	roll(direction)


#### TODO : facto truc comment avec player
var is_moving = false
var is_on_edge = false
var start: Basis
var goal: Basis

func roll(dir: Vector3, do_add_action=true):
	if is_moving:
		return
	
	var g = global_transform
	Utils.switch_parent(self, main)
	global_transform = g
	
	is_moving = true
	if Utils.push_neighbour(self, dir):
		is_moving = false
		return
	is_on_edge = not Utils.get_raycast_collider(self, dir, Vector3.DOWN)
	_offset(dir)
	_animation(dir)
	if do_add_action:
		Actions.add_action(position, Global.map_cube.basis)
		Actions.undo_stack.clear()

func _offset(direction):
	pivot.position += direction / 2 + Vector3.DOWN / 2
	mesh_instance.position -= direction / 2 + Vector3.DOWN / 2

func _animation(dir):
	var axis = dir.cross(Vector3.DOWN)
	start = pivot.basis
	goal = pivot.basis.rotated(axis, PI/2) if not is_on_edge else pivot.basis.rotated(-axis, PI)
	var rotation_tween = get_tree().create_tween()
	var speed = Global.player.speed if not is_on_edge else Global.player.speed * 2
	rotation_tween.tween_method(_tween_basis, 0., 1., speed) 
	await rotation_tween.finished
	_end_animation(dir)

func _tween_basis(t):
	if not is_moving:
		return
	pivot.basis = start.slerp(goal, t)


func _end_animation(dir):
	if not is_moving: # modified elsewhere
		return
	reset_pivot(dir)

var db = false
func _input(_event):
	if Input.is_key_pressed(KEY_B):
		db = true
		
func reset_pivot(direction=Vector3.ZERO):
	is_moving = false
	mesh_instance.position = Vector3.ZERO
	pivot.transform = Transform3D.IDENTITY
	global_position = Global.player.global_position + direction * 2 
	if is_on_edge:
		global_position += Vector3.DOWN
	
	var g = global_transform
	if db: return
	Utils.switch_parent(self, Global.map_cube.cubes)
	global_transform = g

###################

func map_rot(direction: Vector3):
	#mesh_instance.position = Vector3(0, 0.5, 0)
	print("reste ")
	var old_position = global_position
	basis = Global.player.basis
	global_position = old_position

	#pivot.global_transform = Transform3D.IDENTITY


	pass
	#var axis = direction.cross(Vector3.DOWN)
	#position.y -= 0.5
	#position.x -= 0.5
	#basis = basis.rotated(axis, PI / 2)
