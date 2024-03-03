class_name Level extends BaseLevel

@export var _camera_mode:= CameraController.CameraMode.NATURAL
@export var _camera_distance:= 18.5
var end_cube: EndCube
var can_win: bool = false


func _ready():
	camera_controller = CameraController.new(self, _camera_mode, _camera_distance)
	super._ready()
	
	## Check if the is one end cube and assign it
	var end_cubes = map_cube.get_children().filter(func(cube): return cube is EndCube)
	if end_cubes.size() != 1:
		OS.alert("Il ne doit y avoir qu'un fin !", "oups")
		Utils.crash(["Il ne doit y avoir qu'un fin !"])
		return
	end_cube = end_cubes[0]
	
	end_cube.player_touch.connect(
		func(): 
			if can_win:
				# TODO check in a better way that all the async functions are done running (or killed)
				#await input_handler.call_for_change_level()
				input_handler._add_action(self)
				await Utils.wait_while(func(): return player._is_moving)
				#await Utils.wait_while(func(): return input_handler.is_locked())
				LevelManager.win(get_tree())
	)
	single_use_cubes.map(
		func(single_use_cube: SingleUseCube):
			single_use_cube.get_used.connect(func(): update_can_win())
	)
	update_can_win()


func abort_move():
	player.abort_move()


func update_can_win():
	can_win = single_use_cubes.all(func(cube): return cube.is_used)
	end_cube.update_color(can_win)
