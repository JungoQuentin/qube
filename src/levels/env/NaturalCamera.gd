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
	if not _level.player:
		return
	var speed = 30
	var goal = Vector3.ZERO
	if _level.camera.mode == FixedCamera.Mode.FIXED:
		goal = _level.camera.global_position
		print("FIXEEED")
	else:
		goal = _level.player.global_position.normalized() * Level.CAMERA_DISTANCE * (-1 if is_op else 1)
	global_position.x = move_toward(global_position.x, goal.x, delta * speed)
	global_position.y = move_toward(global_position.y, goal.y, delta * speed)
	global_position.z = move_toward(global_position.z, goal.z, delta * speed)
	global_position = global_position.normalized() * Level.CAMERA_DISTANCE
	look_at(Vector3.ZERO, _level.camera.global_basis * Vector3.UP)
