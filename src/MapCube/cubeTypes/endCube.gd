extends StaticBody3D

var TOUCHED_COLOR = Color.from_hsv(293, 0.78, 1, 1)
var tween
var mesh_instance: MeshInstance3D
var mesh: Mesh

func _ready():
	mesh_instance = $MeshInstance3D
	mesh = mesh_instance.mesh
	
func touched():
	Global.surface_touched_animation_start(mesh_instance, tween, Color.WHITE, TOUCHED_COLOR, _animation_end)

func _animation_end():
	mesh_instance.mesh = mesh
	tween = null

func on_leave(): pass