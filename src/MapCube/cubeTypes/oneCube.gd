extends StaticBody3D

var initial_color: Color
var mesh_instance: MeshInstance3D
var mesh: Mesh
var tween
@onready var blockingCube = preload("res://src/MapCube/cubeTypes/blockingCube.tscn")

func _ready():
	mesh_instance = $MeshInstance3D
	mesh = mesh_instance.mesh
	initial_color = mesh.surface_get_material(0).albedo_color

func touched():
	# TODO
	pass

func on_leave():
	blockingCube.instantiate()
	get_parent().add_child(blockingCube)
	blockingCube.position = position
	self.queue_free()

func _animation_end():
	mesh_instance.mesh = mesh
	tween = null
