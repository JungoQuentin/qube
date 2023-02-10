extends StaticBody3D
class_name Cube


@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
#@onready var mesh: Mesh = mesh_instance.mesh
#@onready var initial_color: Color = mesh.surface_get_material(0).albedo_color
#@onready var touched_color: Color = mesh.surface_get_material(0).albedo_color
var mesh: Mesh
var initial_color: Color
var touched_color: Color

var tween: Tween

var BLOCKING_TOUCHED_COLOR = Color.BLACK
var BLOCKING_INIT_COLOR = Color.DARK_GRAY

func _ready():
	mesh = mesh_instance.mesh
	initial_color = mesh.surface_get_material(0).albedo_color
	touched_color = mesh.surface_get_material(0).albedo_color

func on_touch():
	_touched_animation_start()

func on_leave():
	pass

func _animation_end():
	mesh_instance.mesh = mesh
	tween = null

func _touched_animation_start():
	var _tmp_mesh = mesh_instance.mesh.duplicate(true)
	mesh_instance.mesh = _tmp_mesh
	var _material = _tmp_mesh.surface_get_material(0)
	if tween:
		tween.pause()
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_material, "albedo_color", touched_color, 0.05)
	tween.tween_property(_material, "albedo_color", initial_color, 1)
	tween.tween_callback(_animation_end)
	tween.play()
	# TODO add sound 
	# idee : une note jouee par un xylophone, chaque bloque a une note differente d'une gamme