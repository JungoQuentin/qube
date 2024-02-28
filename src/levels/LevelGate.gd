class_name LevelGate extends BaseLevel


func _ready():
	camera_controller = CameraController.new(self, CameraController.CameraMode.FIXED, 30)
	super._ready()
	if LevelManager.get_current_progression().global_position_entry_point.is_equal_approx(Transform3D.IDENTITY):
		LevelManager.get_current_progression().global_position_entry_point = player.global_transform
	else:
		player.global_transform = LevelManager.get_current_progression().global_position_entry_point
	camera_controller.player_want_to_move()


func player_start_move(_direction: Vector3):
	# TODO round this up ?
	LevelManager.get_current_progression().global_position_entry_point = player.global_transform
	Save.save()
	super.player_start_move(_direction)
