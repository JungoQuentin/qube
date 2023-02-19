extends StaticBody3D
class_name Cube

enum { SWITCH, NORMAL, SINGLE_USE, BLOCKING, END, START, MOVING }

@onready var collision_shape: CollisionShape3D = self.find_child("CollisionShape3D")
@onready var mesh_instance: MeshInstance3D = self.find_child("MeshInstance3D")
@onready var mesh: Mesh = mesh_instance.mesh
var initial_color: Color
var touched_color: Color
var touch_tween: Tween
var cube_type = NORMAL

func _ready():
	mesh.size = Vector3.ONE * Colors.cube_scale
	collision_shape.shape.size = mesh.size

func on_touch(_direction: Vector3, _cube):
	_touched_animation_start(mesh_instance, touched_color, initial_color)

func on_leave():
	pass

func _animation_end():
	mesh_instance.mesh = mesh
	touch_tween = null

func _touched_animation_start(_mesh_instance: MeshInstance3D, _touched_color: Color, _initial_color: Color):
	var _tmp_mesh = _mesh_instance.mesh.duplicate(true)
	_mesh_instance.mesh = _tmp_mesh
	var _material = _tmp_mesh.surface_get_material(0)
	if touch_tween:
		touch_tween.pause()
		touch_tween.kill()
	touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	touch_tween.tween_property(_material, "albedo_color", _touched_color, 0.05)
	touch_tween.tween_property(_material, "albedo_color", _initial_color, 1)
	touch_tween.tween_callback(_animation_end)
	touch_tween.play()
	# TODO add sound 
	# idee : une note jouee par un xylophone, chaque bloque a une note differente d'une gamme

### Pour envoyer le player en arriere (blockingCube, movingCube, SingleUseCube)
func _send_cube_back(direction, to_roll):
	await to_roll.end_roll
	to_roll.order_roll(-direction)
	# TODO attention au truc infini avec les singleUseCube
	Actions.actions.pop_back()

func is_blocking() -> bool:
	return cube_type == BLOCKING or (cube_type == SINGLE_USE and self.is_used)
