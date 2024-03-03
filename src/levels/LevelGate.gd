class_name LevelGate extends BaseLevel

var level_gate_cubes: Array

func _ready():
	camera_controller = CameraController.new(self, CameraController.CameraMode.FIXED, 30)
	super._ready()
	if LevelManager.get_current_progression().global_position_entry_point.is_equal_approx(Transform3D.IDENTITY):
		LevelManager.get_current_progression().global_position_entry_point = player.global_transform
	else:
		player.global_transform = LevelManager.get_current_progression().global_position_entry_point
	camera_controller.player_want_to_move()
	player.start_move.connect(_on_player_start_move)
	level_gate_cubes = map_cube.get_children().filter(func(cube): return cube is LevelGateCube)
	level_gate_cubes.map(func(cube: LevelGateCube): cube.player_touch.connect(func(): _on_player_touch_level_gate_cube(cube)))



func _on_player_start_move():
	# TODO round this up ?
	LevelManager.get_current_progression().global_position_entry_point = player.global_transform
	Save.save()

func _on_player_touch_level_gate_cube(cube: LevelGateCube):
	print("go in level animation !") # TODO
	input_handler._add_action(self)
	await Utils.sleep(1.)
	LevelManager.goto_level_by_packed(cube.destination, get_tree())
