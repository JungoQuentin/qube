class_name NaturalCamera extends Camera3D

const camera_fov = 30.
@onready var _level: Level = get_tree().current_scene
var is_moving = false
var last_face: Vector3
var is_op:= false


func _ready():
	fov = camera_fov
	position.z = Level.CAMERA_DISTANCE
	last_face = global_position.normalized()


func _process(delta):
	if _level.player:
		global_position = _level.player.global_position.normalized() * Level.CAMERA_DISTANCE * (-1 if is_op else 1)
		look_at(Vector3.ZERO, _level.camera.global_basis * Vector3.UP)
