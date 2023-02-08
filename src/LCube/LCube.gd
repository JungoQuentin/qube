extends StaticBody3D

var tween

# PURPLE
var TOUCHED_COLOR = Color.from_hsv(293, 0.78, 1, 1)
var BASIC_COLOR = Color.WHITE

var mesh_instance: MeshInstance3D
var mesh: Mesh

func _ready():
	mesh_instance = $MeshInstance3D
	mesh = mesh_instance.mesh
	
func touched():
	_animation_start()
	# TODO add sound 
	# idee : une note jouee par un xylophone, chaque bloque a une note differente d'une gamme

func _animation_start():
	var _tmp_mesh = mesh.duplicate(true)
	mesh_instance.mesh = _tmp_mesh
	var _material = _tmp_mesh.surface_get_material(0)
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_material, "albedo_color", TOUCHED_COLOR, 0.05)
	tween.tween_property(_material, "albedo_color", BASIC_COLOR, 1)
	tween.tween_callback(_animation_end)
	tween.play()

func _animation_end():
	mesh_instance.mesh = mesh
	tween = null