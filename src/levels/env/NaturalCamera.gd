class_name NaturalCamera extends Camera3D

const camera_fov = 30.
@onready var _level: Level = get_tree().current_scene
var is_moving = false
var last_face: Vector3
var is_op:= false
var camera_up: Vector3

func _ready():
	fov = camera_fov
	position.z = Level.CAMERA_DISTANCE
	last_face = global_position.normalized()


func _process(delta):
	if not _level.player:
		return
	var speed = 30
	var tourne_autour_du_coin_speed = 3
	var goal = Vector3.ZERO
	var camera_up_goal = _level.camera.global_basis * Vector3.UP
	if _level.camera.mode == FixedCamera.Mode.FIXED:
		goal = _level.camera.global_position
		print("FIXEEED")
	else:
		goal = _level.player.global_position.normalized() * Level.CAMERA_DISTANCE * (-1 if is_op else 1)
	global_position.x = move_toward(global_position.x, goal.x, delta * speed)
	global_position.y = move_toward(global_position.y, goal.y, delta * speed)
	global_position.z = move_toward(global_position.z, goal.z, delta * speed)
	global_position = global_position.normalized() * Level.CAMERA_DISTANCE
	camera_up.x = move_toward(camera_up.x, camera_up_goal.x, delta * tourne_autour_du_coin_speed)
	camera_up.y = move_toward(camera_up.y, camera_up_goal.y, delta * tourne_autour_du_coin_speed)
	camera_up.z = move_toward(camera_up.z, camera_up_goal.z, delta * tourne_autour_du_coin_speed)
	look_at(Vector3.ZERO, camera_up)
