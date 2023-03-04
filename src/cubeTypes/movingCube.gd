extends Cube
class_name MovingCube

@onready var main = get_tree().get_current_scene()
@onready var speed: float = Level.player.speed
var is_moving = false
var is_on_edge = false
var _start_transform: Transform3D
var _down_roll_send_back = false
signal end_roll

func _ready():
	super._ready()
	initial_color = Colors.moving_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color
	_start_transform = transform

func on_push(direction: Vector3):
	var move_logic = CubeMoveLogic.new(self, direction).init_forward_roll()
	if move_logic.has_neighbour:
		is_moving = false
		await Level.player.end_roll
		await get_tree().process_frame
		end_roll.emit(false)
		move_logic.queue_free()
		return
	_roll(direction, move_logic)

func on_touch(direction: Vector3, cube):
	super.on_touch(direction, cube)
	_send_cube_back(direction, cube)
	if not cube is Cube:
		_down_roll(direction)

## Called another entity to make us roll
func order_roll(direction: Vector3, _ordering_entity: Node3D=null):
	if _down_roll_send_back:
		_down_roll(direction, -direction)
		_down_roll_send_back = false
	else:
		on_push(direction)

func _down_roll(direction: Vector3, r_direction=null):
	if r_direction == null:
		r_direction = direction
	var rotator = Node3D.new()
	rotator.name = "ROTATOR"
	main.add_child(rotator)
	var axis = direction.cross(Vector3.DOWN)
	basis = basis.rotated(axis, PI / 2)
	var r_axis = r_direction.cross(Vector3.DOWN)
	rotator.basis = rotator.basis.rotated(r_axis, PI / 2)
	var old_parent = Utils.switch_parent(self, rotator, true)
	_roll(direction, CubeMoveLogic.new(self, direction).init_forward_roll())
	_down_roll_send_back = await self.end_roll
	if _down_roll_send_back: 
		return
	Utils.switch_parent(self, old_parent, true)
	rotator.queue_free()

func _roll(direction: Vector3, move_logic: MoveLogic):
	await move_logic.roll()
	move_logic.reset_pivot()
	var reset_direction = direction
	if is_on_edge:
		reset_direction += Vector3.DOWN
	var block = await move_logic.reset_position(reset_direction)
	is_moving = false
	end_roll.emit(block and (block.is_blocking() or block is MovingCube))
	move_logic.queue_free()

func replace_after_map_rotation():
	var old_position = global_position
	basis = Level.player.basis
	global_position = old_position

func reset():
	transform = _start_transform