class_name LevelGate extends BaseLevel

const INITIAL_USER_POSITION = Vector3(0, 0, 6)
var level_gate_cubes: Array


func _ready():
	camera_controller = CameraController.new(self, CameraController.CameraMode.FIXED, 30)
	super._ready()
	LevelManager.get_current_progression().entry_point_state.apply(self, true)
	camera_controller.player_want_to_move()
	player.start_move.connect(_on_player_start_move)
	level_gate_cubes = map_cube.get_children().filter(func(cube): return cube is LevelGateCube)
	level_gate_cubes.map(func(cube: LevelGateCube): cube.player_touch.connect(func(): _on_player_touch_level_gate_cube(cube)))


func _on_player_start_move():
	LevelManager.get_current_progression().entry_point_state = LevelState.from_level(self, true)
	Save.save()


func _on_player_touch_level_gate_cube(cube: LevelGateCube):
	if cube.destination == null:
		return
	print("go in level animation !") # TODO
	input_handler._add_action(self)
	await Utils.sleep(1.)
	LevelManager.goto_level_by_packed(cube.destination, get_tree())
