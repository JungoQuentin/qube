extends StaticBody3D

@onready var blockingCubePreload = preload("res://src/MapCube/cubeTypes/blockingCube.tscn")

@export var basicColor = Color.WHITE
@export var touchedColor = Color.WHITE

var initial_color: Color
var mesh_instance: MeshInstance3D
var mesh: Mesh
var tween

func _ready():
	mesh_instance = $MeshInstance3D
	mesh = mesh_instance.mesh
	initial_color = mesh.surface_get_material(0).albedo_color

func touched():
	# TODO
	pass

func on_leave():
	var blockingCube = blockingCubePreload.instantiate()
	get_parent().add_child(blockingCube)
	blockingCube.position = position
	self.queue_free()

func _animation_end():
	mesh_instance.mesh = mesh
	tween = null
