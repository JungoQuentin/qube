extends StaticBody3D
class_name Cube

enum Type { NORMAL, END, SNOW_BALL, SINGLE_USE, BLOCKING, SWITCH, ICE, HOLE, GATE, LASER }
@export var cubeType: Type
@onready var _collision_shape: CollisionShape3D = self.find_child("CollisionShape3D")
@onready var _mesh_instance: MeshInstance3D = self.find_child("MeshInstance3D")
@onready var _mesh: Mesh = _mesh_instance.mesh
@onready var _color_set: ColorSet = get_tree().current_scene.color_set
var _initial_color: Color
var _touched_color: Color
var _touch_tween: Tween


func _ready():
	_mesh.size = Vector3.ONE * _color_set.cube_scale
	_collision_shape.shape.size = Vector3.ONE * _color_set.cube_scale
	_set_colors()
	_mesh_instance.set_surface_override_material(0, _mesh_instance.get_surface_override_material(0).duplicate(true))
	_mesh_instance.get_surface_override_material(0).albedo_color = _initial_color


func _set_colors():
	_initial_color = _color_set.get_initial_color(Cube.object_to_type(self))
	_touched_color = ColorSet.darker(_initial_color)

## Called when the player, or a movingCube touch the cube (take the toucher as _cube: Node3D)
func on_touch():
	_touched_animation_start()

## Called when the player, or a movingCube leave (in the edge of the map, it don't leave if the player move to the same cube)
func on_leave():
	pass

## Lauch the animation when the cube is touched
func _touched_animation_start(touched_color = _touched_color, initial_color = _initial_color):
	var material = _mesh_instance.get_surface_override_material(0)
	if _touch_tween_running():
		_touch_tween.kill()
	_touch_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	_touch_tween.tween_property(material, "albedo_color", touched_color, 0.05)
	_touch_tween.tween_property(material, "albedo_color", initial_color, 1)
	_touch_tween.tween_callback(func(): _touch_tween.kill())

## Check if the cube will reject anything that enter
func is_rejecting() -> bool:
	return (self is BlockingCube) or (self is SingleUseCube and self.is_used) or (self is LevelGateCube and not self.is_gate_open.call())

## Check if is the kind that is on the floor
func is_floor() -> bool:
	return (Cube.object_to_type(self) in [Type.NORMAL, Type.END, Type.SWITCH, Type.SINGLE_USE, Type.HOLE, Type.BLOCKING, Type.ICE]) or \
			(self is MovingCube and self.in_a_hole)

## Check if the touch tween exists, is_valid and is_running
func _touch_tween_running() -> bool:
	return _touch_tween and _touch_tween.is_valid() and _touch_tween.is_running()

## Get the Type by duck typing a cube
static func object_to_type(cube: Cube) -> Type:
	if cube is NormalCube:
		return Type.NORMAL
	elif cube is LevelGateCube:
		return Type.GATE
	elif cube is BlockingCube:
		return Type.BLOCKING
	elif cube is EndCube:
		return Type.END
	elif cube is SingleUseCube:
		return Type.SINGLE_USE
	elif cube is IceCube:
		return Type.ICE
	elif cube is HoleCube:
		return Type.HOLE
	elif cube is SwitchCube:
		return Type.SWITCH
	elif cube is LaserCube:
		return Type.LASER
	elif cube is SnowBallCube:
		return Type.SNOW_BALL
	return Type.NORMAL
