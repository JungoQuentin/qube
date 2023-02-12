extends Node3D 

@onready var pivot = $Pivot
@onready var mesh_instance: MeshInstance3D = $Pivot/Mesh

@export var max_transparency: float = 1
@export var min_transparency: float = 0.3
@export var speed: float = 0.2 #* 10

var loaded = false
var is_rolling = false 
var start
var goal
var t = 0.0
var is_on_edge = false

var we_are_on_this_cube_now = null


func _ready():
	pivot.set_disable_scale(true)
	Global.player = self
	mesh_instance.mesh.surface_get_material(0).albedo_color = Color.AQUA
	#_start_transparence_animation()
	await _set_start_pos()

func _set_start_pos():
	await Utils.wait_while(func(): return Global.startCube == null)
	position = Global.startCube.global_position + Vector3.UP / 2
	we_are_on_this_cube_now = Global.startCube
		
func _input(_event):
	if is_rolling or Global.map_cube.is_rotating:
		return
	var forward = Vector3.FORWARD
	if Input.is_action_pressed("top"):
		roll(forward)
	if Input.is_action_pressed("bottom"):
		roll(-forward)
	if Input.is_action_pressed("right"):
		roll(forward.cross(Vector3.UP))
	if Input.is_action_pressed("left"):
		roll(-forward.cross(Vector3.UP))

func reset_pivot(direction=Vector3.ZERO):
	t = 0.0
	mesh_instance.transform.origin = Vector3(0, 0.5, 0)
	pivot.transform = Transform3D.IDENTITY
	self.transform.origin += direction

	var block = Utils.get_raycast_collider(self, Vector3.UP / 2, Vector3.DOWN)
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != block:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = block
	if block:
		block.on_touch()

func roll(dir: Vector3, do_add_action=true):
	if is_rolling or Global.map_cube.is_rotating:
		return
	is_rolling = true
	if _check_neighbour(dir):
		is_rolling = false
		return
	Global.direction = dir
	_check_edge(dir)
	_offset(dir)
	_set_animation(dir)

	if do_add_action:
		Actions.add_action(position, Global.map_cube.basis)
		Actions.undo_stack.clear()

func _check_neighbour(dir: Vector3) -> bool:
	var neighbour_block = Utils.get_raycast_collider(self, Vector3.UP / 2, dir)
	if neighbour_block == null:
		return false
	if neighbour_block.cube_type != Cube.MOVING:
		Log.crash("comment un block voisin peut etre autre chose qu'un moving cube ??")
	neighbour_block.on_push(dir)
	return true

func _check_edge(dir):
	var collider = Utils.get_raycast_collider(self, dir + Vector3.UP / 2, Vector3.DOWN)
	is_on_edge = !collider
	if is_on_edge:
		Global.map_cube.start_cube_rotation(dir)

func _offset(dir):
	pivot.translate(dir / 2)
	mesh_instance.transform.origin -= dir /2

var tween

func _set_animation(dir):
	var axis = dir.cross(Vector3.DOWN)
	goal = pivot.basis.rotated(axis, PI/2)
	var goal_e = pivot.basis.rotated(axis, PI-0.01)
	var time = speed

	if tween != null:
		tween.stop()
		tween.kill()
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(pivot, "basis:x", goal.x, time)
	tween.parallel().tween_property(pivot, "basis:y", goal.y, time)
	tween.parallel().tween_property(pivot, "basis:z", goal.z, time)
	if is_on_edge:
		tween.tween_property(pivot, "basis:x", goal_e.x, time)
		tween.parallel().tween_property(pivot, "basis:y", goal_e.y, time)
		tween.parallel().tween_property(pivot, "basis:z", goal_e.z, time)
		pass
	tween.tween_callback(_animation_end.bind(dir))

func _animation_end(dir):
	is_rolling = false
	tween = null
	if not is_on_edge:
		reset_pivot(dir)
#####

func _start_transparence_animation():
	var material = mesh_instance.mesh.surface_get_material(0)
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(material, "albedo_color:a", min_transparency, 2)
	tween.tween_property(material, "albedo_color:a", max_transparency, 2)
	tween.tween_callback(_start_transparence_animation)
	tween.play()

func reset():
	if not is_on_edge:
		reset_pivot()
	is_rolling = false
	_set_start_pos()
