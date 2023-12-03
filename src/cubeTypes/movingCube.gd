extends Cube
class_name MovingCube

#region DECLARATION

@onready var main = get_tree().get_current_scene()
var speed: float
var is_moving = false
signal end_roll

#endregion


func _ready():
	super._ready()
	initial_color = Colors.moving_cube_init_color
	touched_color = Colors.darker(initial_color)
	mesh.surface_get_material(0).albedo_color = initial_color


func on_push(direction: Vector3, floor_direction):
	pass # TODO
