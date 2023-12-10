extends StaticBody3D
class_name Cube

enum Type { NORMAL, END, MOVING, SINGLE_USE, BLOCKING, SWITCH, ICE, HOLE }
@export var cubeType: int
@onready var _collision_shape: CollisionShape3D = self.find_child("CollisionShape3D")
@onready var _mesh_instance: MeshInstance3D = self.find_child("MeshInstance3D")
@onready var _mesh: Mesh = _mesh_instance.mesh
var _initial_color: Color
var _touched_color: Color
var _touch_tween: Tween


func _ready():
	_mesh.size = Vector3.ONE * Colors.cube_scale
	_collision_shape.shape.size = _mesh.size
	_initial_color = Colors.get_initial_color(self)
	_touched_color = Colors.darker(_initial_color)
	_mesh_instance.set_surface_override_material(0, _mesh_instance.get_surface_override_material(0).duplicate(true))
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color


## Called when the player, or a movingCube touch the cube (take the toucher as _cube: Node3D)
func on_touch():
	_touched_animation_start()

## Called when the player, or a movingCube leave (in the edge of the map, it don't leave if the player move to the same cube)
func on_leave():
	pass

## Lauch the animation when the cube is touched
func _touched_animation_start():
	var material = _mesh_instance.get_surface_override_material(0)
	if _touch_tween_running():
		_touch_tween.kill()
	_touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	_touch_tween.tween_property(material, "albedo_color", _touched_color, 0.05)
	_touch_tween.tween_property(material, "albedo_color", _initial_color, 1)
	_touch_tween.tween_callback(func(): _touch_tween.kill())

## Check if the cube will reject anything that enter
func is_rejecting() -> bool:
	return (self is BlockingCube) or (self is SingleUseCube and self.is_used)

## Check if the touch tween exists, is_valid and is_running
func _touch_tween_running() -> bool:
	return _touch_tween and _touch_tween.is_valid() and _touch_tween.is_running()

## Get the Type by duck typing a cube
static func object_to_type(cube: Cube) -> Type:
	if cube is NormalCube:
		return Type.NORMAL
	elif cube is BlockingCube:
		return Type.BLOCKING
	elif cube is EndCube:
		return Type.END
	elif cube is SingleUseCube:
		return Type.SINGLE_USE
	elif cube is MovingCube:
		return Type.MOVING
	elif cube is IceCube:
		return Type.ICE
	elif cube is HoleCube:
		return Type.HOLE
	return Type.NORMAL
