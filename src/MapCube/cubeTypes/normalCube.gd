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
	# TODO improve ! (lauch the good node instead of all...)
	var n = randi_range(0, 7)
	print(n)
	$Music.get_child(n).play()

func _animation_end():
	mesh_instance.mesh = mesh
	tween = null