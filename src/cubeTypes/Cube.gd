extends StaticBody3D
class_name Cube

enum { SWITCH, NORMAL, SINGLE_USE, BLOCKING, END, START, MOVING }

@onready var collision_shape: CollisionShape3D = self.find_child("CollisionShape3D")
@onready var mesh_instance: MeshInstance3D = self.find_child("MeshInstance3D")
@onready var mesh: Mesh = mesh_instance.mesh
var initial_color: Color
var touched_color: Color
var touch_tween: Tween

func _ready():
	mesh.size = Vector3.ONE * Colors.cube_scale
	collision_shape.shape.size = mesh.size

## Called when the player, or a movingCube touch the cube (take the toucher as _cube: Node3D)
func on_touch():
	_touched_animation_start(mesh_instance, touched_color, initial_color)

## Called when the player, or a movingCube leave (in the edge of the map, it don't leave if the player move to the same cube)
func on_leave():
	pass

## Lauch the animation when the cube is touched
## TODO add sound 
func _touched_animation_start(_mesh_instance: MeshInstance3D, _touched_color: Color, _initial_color: Color):
	var _tmp_mesh = _mesh_instance.mesh.duplicate(true)
	_mesh_instance.mesh = _tmp_mesh
	var _material = _tmp_mesh.surface_get_material(0)
	if touch_tween:
		touch_tween.pause()
		touch_tween.kill()
	touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	touch_tween.tween_property(_material, "albedo_color", _touched_color, 0.05)
	touch_tween.tween_property(_material, "albedo_color", _initial_color, 1)
	touch_tween.tween_callback(_animation_end)
	touch_tween.play()

## Set the mesh to the initial mesh and reset the touch_tween
func _animation_end():
	mesh_instance.mesh = mesh
	touch_tween = null

## Check if the cube will reject anything that enter
func is_rejecting() -> bool:
	return (self is BlockingCube) or (self is SingleUseCube and self.is_used)
