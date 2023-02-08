extends StaticBody3D

var initial_color: Color
var mesh_instance: MeshInstance3D
var mesh: Mesh
var tween

func _ready():
	mesh_instance = $MeshInstance3D
	mesh = mesh_instance.mesh
	initial_color = mesh.surface_get_material(0).albedo_color

func touched():
	Global.surface_touched_animation_start(mesh_instance, tween, initial_color, Color.BLACK, _animation_end)
	await Global.wait_player_end_rolling()
	Global.player.roll(-Global.direction)

func _animation_end():
	mesh_instance.mesh = mesh
	tween = null