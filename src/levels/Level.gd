class_name Level extends BaseLevel

@export var _camera_mode:= CameraController.CameraMode.NATURAL
@export var _camera_distance:= 18.5
var end_cube: EndCube


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
	
	update_can_win()

func abort_move():
	player.abort_move()


func player_start_move(_direction: Vector3):
	super.player_end_move()
	update_can_win()


func player_end_move():
	super.player_end_move()
	update_can_win()


func update_can_win():
	end_cube.can_win = single_use_cubes.all(func(cube): return cube.is_used)
