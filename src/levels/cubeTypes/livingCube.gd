extends Cube
class_name LivingCube

enum Pattern { FOLLOW }
@export var pattern: Pattern
@onready var _level: Level = get_tree().current_scene





func player_move():
	if pattern == Pattern.FOLLOW:
		if not _is_on_same_face_that_player():
			return
		print("haha !")


func _is_on_same_face_that_player() -> bool:
	#var camera = _level.camera
	var camera_basis = _level.camera.basis
	var floor_direction = camera_basis * Vector3.FORWARD
	var axis = "x";
	if floor_direction.x != 0:
		axis = "x"
	elif floor_direction.y != 0:
		axis = "y"
	elif  floor_direction.z != 0:
		axis = "z"
	print(axis)

	# TODO
	# selon la camera
	# choper l'axe
	# voir si il est different pour les deux...:w
	return true
