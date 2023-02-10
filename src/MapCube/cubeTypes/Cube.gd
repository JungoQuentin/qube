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

func _ready():
	mesh = mesh_instance.mesh
	initial_color = mesh.surface_get_material(0).albedo_color
	touched_color = mesh.surface_get_material(0).albedo_color

func on_touch():
	pass

func on_leave():
	pass

func _start_touch_animation():
	Global.surface_touched_animation_start(mesh_instance, tween, initial_color, touched_color, _animation_end)

func _animation_end():
	mesh_instance.mesh = mesh
	tween = null
