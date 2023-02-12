extends Cube

@onready var pivot = $Pivot

func _ready():
	super._ready()
	cube_type = MOVING
	initial_color = Global.moving_cube_init_color
	touched_color = Global.moving_cube_touched_color
	mesh.surface_get_material(0).albedo_color = initial_color

func on_touch():
	super.on_touch()

func on_leave():
	super.on_leave()

func on_push(direction: Vector3):
	return


var is_moving = false


func roll(dir: Vector3, do_add_action=true):
	if is_moving:
		return
	is_moving = true
	if _check_neighbour(dir):
		pass
		#is_rolling = false
		#return
	#_check_edge(dir)
	#_offset(dir)
	#_set_animation(dir)

	
	# TODO
	if do_add_action:
		Actions.add_action(position, Global.map_cube.basis)
		Actions.undo_stack.clear()


func _check_neighbour(dir: Vector3) -> bool:
	return false
	#var neighbour_raycast = _new_raycast(Vector3.UP + dir, Vector3.ZERO)
	#print(neighbour_raycast.get_collider())
	#if not neighbour_raycast.is_colliding(): 
	#	return false
	#var neighbour_block = neighbour_raycast.get_collider()
	#if neighbour_block.cube_type != Cube.MOVING:
	#	Log.crash("comment un block voisin peut etre autre chose qu'un moving cube ??")
	#neighbour_block.on_push(dir)
	#neighbour_raycast.queue_free()
	#return true
