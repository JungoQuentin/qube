extends Cube

@onready var main = get_tree().get_current_scene()
@onready var speed: float = Global.player.speed
var is_moving = false
var is_on_edge = false
var _start_transform: Transform3D
signal end_roll

func _ready():
	super._ready()

	# TODO refacto auto => detecter le type de cube et lui appliquer la couleur, ...
	cube_type = MOVING
	initial_color = Colors.moving_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color
	_start_transform = transform

func on_push(direction: Vector3):
	var move_logic = MoveLogic.new(self, direction).init_forward_roll()
	if move_logic.has_neighbour:
		is_moving = false
		await Global.player.end_roll
		await get_tree().process_frame
		end_roll.emit(false)
		move_logic.queue_free()
		return
	_roll(direction, move_logic)

func on_touch(direction: Vector3, cube):
	super.on_touch(direction, cube)
	_send_cube_back(direction, cube)
	if cube.get("cube_type") == null:
		_down_roll(direction)

func order_roll(direction: Vector3):
	on_push(direction)

func _down_roll(direction: Vector3):
	var rotator = Node3D.new()
	main.add_child(rotator)
	var axis = direction.cross(Vector3.DOWN)
	rotator.basis = rotator.basis.rotated(axis, PI / 2)
	basis = basis.rotated(axis, PI / 2)
	var old_parent = Utils.switch_parent(self, rotator, true)
	await _roll(direction, MoveLogic.new(self, direction).init_forward_roll())
	Utils.switch_parent(self, old_parent, true)
	rotator.queue_free()

func _roll(direction: Vector3, move_logic: MoveLogic):
	move_logic.offset()
	await move_logic.roll()
	move_logic.reset_pivot()
	var reset_direction = direction
	if is_on_edge:
		reset_direction += Vector3.DOWN
	var block = await move_logic.reset_position(reset_direction)
	is_moving = false
	end_roll.emit(block and block.is_blocking() or block.cube_type == Cube.MOVING)
	move_logic.queue_free()

func replace_after_map_rotation():
	var old_position = global_position
	basis = Global.player.basis
	global_position = old_position

func reset():
	transform = _start_transform
