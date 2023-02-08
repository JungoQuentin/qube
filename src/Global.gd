extends Node

var player: Node3D
var cube: Node3D 
var direction: Vector3
var rotator: Node3D
var fade: float = 2.4

func _ready():
	_start_animation()

func _start_animation():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "fade", 0.5, 2)
	tween.tween_property(self, "fade", 2.0, 2)
	tween.tween_callback(_start_animation)
	tween.play()

func get_cell_position(world_point) -> Vector3i:
	return cube.grid_map.local_to_map(world_point) - Vector3i(cube.grid_map.position)