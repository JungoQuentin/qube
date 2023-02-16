extends Cube

@onready var main = get_tree().get_current_scene()
@onready var speed: float = Global.player.speed
var has_neighbour: bool
var is_moving = false # TODO pas besoin de is_moving ??
var is_on_edge = false

func _ready():
	super._ready()

	# TODO refacto auto => detecter le type de cube et lui appliquer la couleur, ...
	cube_type = MOVING
	initial_color = Colors.moving_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color

func on_push(direction: Vector3):
	var move_logic = MoveLogic.new_roll(self, direction)
	if has_neighbour:
		is_moving = false
		return
	_roll(direction, move_logic)

func _roll(direction: Vector3, move_logic: MoveLogic):
	await move_logic.roll()
	move_logic.reset_pivot()
	var reset_direction = direction
	if is_on_edge:
		reset_direction += Vector3.DOWN
	await move_logic.reset_position(reset_direction)
	is_moving = false
	# TODO est-ce qu'il revient comme le joueur sur certaine case ?


func replace_after_map_rotation(direction: Vector3):
	var old_position = global_position
	basis = Global.player.basis
	global_position = old_position