extends StaticBody3D
class_name Cube

enum Type { NORMAL, END, MOVING, SINGLE_USE, BLOCKING, SWITCH, ICE }
@export var cubeType: int

@onready var collision_shape: CollisionShape3D = self.find_child("CollisionShape3D")
@onready var mesh_instance: MeshInstance3D = self.find_child("MeshInstance3D")
@onready var mesh: Mesh = mesh_instance.mesh
var initial_color: Color
var touched_color: Color
var touch_tween: Tween


static func object_to_type(object: Cube) -> Type:
	if object is NormalCube:
		return Type.NORMAL
	elif object is BlockingCube:
		return Type.BLOCKING
	elif object is EndCube:
		return Type.END
	elif object is SingleUseCube:
		return Type.SINGLE_USE
	elif object is MovingCube:
		return Type.MOVING
	elif object is IceCube:
		return Type.ICE
	return Type.NORMAL


func _ready():
	mesh.size = Vector3.ONE * Colors.cube_scale
	collision_shape.shape.size = mesh.size
	initial_color = Colors.get_initial_color(self)
	touched_color = Colors.darker(initial_color)
	mesh_instance.set_surface_override_material(0, mesh_instance.get_surface_override_material(0).duplicate(true))
	mesh_instance.get_surface_override_material(0).albedo_color = initial_color


## Called when the player, or a movingCube touch the cube (take the toucher as _cube: Node3D)
func on_touch():
	_touched_animation_start(touched_color, initial_color)

## Called when the player, or a movingCube leave (in the edge of the map, it don't leave if the player move to the same cube)
func on_leave():
	pass

## Lauch the animation when the cube is touched
## TODO add sound 
func _touched_animation_start(_touched_color: Color, _initial_color: Color):
	var _material = mesh_instance.get_surface_override_material(0)
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
