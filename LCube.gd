extends StaticBody3D

# PURPLE
var TOUCHED_COLOR: Color = Color.from_hsv(293, 0.78, 1, 1)

var mesh_instance: MeshInstance3D
var mesh: Mesh

var material
var _is_processing = false

func _ready():
	mesh_instance = $MeshInstance3D
	mesh = mesh_instance.mesh

func _process(_delta):
	if not _is_processing:
		return
	mesh.surface_set_material(0, material)
	

func _stop_processing():
	_is_processing = false

func touched():
	_is_processing = true
	material = mesh.surface_get_material(0)
	var init_color = material.albedo_color
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(material, "albedo_color", TOUCHED_COLOR, 0.1)
	tween.tween_property(material, "albedo_color", init_color, 1)
	tween.tween_callback(_stop_processing)
	tween.play()