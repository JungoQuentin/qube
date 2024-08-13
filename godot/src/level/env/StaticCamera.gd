class_name StaticCamera extends Camera3D

var side:= false


func _init(_side:= false):
	side = _side


func _ready():
	fov = 30.
	global_position = Vector3.ONE.normalized() * CameraController.CAMERA_DISTANCE * (1 if side else -1)
	look_at(Vector3.ZERO)
