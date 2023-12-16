extends Cube
class_name LivingCube

enum Pattern { FOLLOW, ASYMETRIC }
@export var pattern: Pattern
@onready var _level: Level = get_tree().current_scene
var is_moving:= false
var speed: float
var we_are_on_this_cube_now: Cube


func _ready():
	super._ready()
	speed = _level.player.speed


func player_move(player_direction: Vector3):
	if not _is_on_same_face_that_player():
		return
	if is_moving:
		# TODO player cant move if a living cube is moving ?
		printerr(self.name, "living cube, is already moving...")
		return
	is_moving = true
	var camera_basis = _level.camera.basis
	var floor_direction = camera_basis * Vector3.FORWARD
	match pattern:
		Pattern.FOLLOW: 
			var diff = _level.player.global_position - global_position
			await _roll(_flatten_other_axis(diff), floor_direction)
		Pattern.ASYMETRIC:
			await _roll(-player_direction, floor_direction)
	is_moving = false


func _roll(direction: Vector3, floor_direction: Vector3):
	var move_logic = CubeMoveLogic.new(self, direction, floor_direction).init_forward_roll()
	if move_logic.is_going_to_hole:
		return
	if move_logic._is_going_to_change_face:
		if pattern == Pattern.ASYMETRIC:
			return
		printerr("living cube, should not follow by going to other face")
		get_tree().quit()
		return
	var neighbour: Cube = Utils.get_raycast_collider(_level, global_position, move_logic._direction)
	
	if move_logic.floor_goal is IceCube:
		if neighbour != null:
			return
		var is_going_to_change_face_by_slide = move_logic.floor_goal.will_change_face(move_logic._direction, move_logic._floor_direction)
		if is_going_to_change_face_by_slide:
			if pattern == Pattern.ASYMETRIC:
				return
			printerr("living cube, should not follow by going to other face")
			get_tree().quit()
			return
		var new_position = move_logic.floor_goal.get_end_slide(move_logic._direction, move_logic._floor_direction)
		global_position = new_position - move_logic._floor_direction

	## if our neighbour is a MovingCube, we try to push him
	if neighbour is MovingCube:
		if neighbour.can_push(move_logic._direction, move_logic._floor_direction):
			neighbour.on_push(move_logic._direction, move_logic._floor_direction)
		else:
			return
	
	await move_logic.roll()
	
	## roll us back if our goal is rejecting
	if move_logic.floor_goal and move_logic.floor_goal.is_rejecting():
		await move_logic.roll_back()
		move_logic.remove_pivot()
		return
	
	## leave old floor and set new
	if we_are_on_this_cube_now != null and we_are_on_this_cube_now != move_logic.floor_goal:
		we_are_on_this_cube_now.on_leave()
	we_are_on_this_cube_now = move_logic.floor_goal

	move_logic.remove_pivot()


func _is_on_same_face_that_player() -> bool:
	var floor_direction = _level.camera.basis * Vector3.FORWARD
	match abs(floor_direction).max_axis_index():
		Vector3.AXIS_X: return global_position.x == _level.player.global_position.x
		Vector3.AXIS_Y: return global_position.y == _level.player.global_position.y
		Vector3.AXIS_Z: return global_position.z == _level.player.global_position.z
		_: 
			printerr("math problem")
			get_tree().quit()
			return false


func _axis_str(axis: int) -> String:
	match axis:
		Vector3.AXIS_X: return "axe x"
		Vector3.AXIS_Y: return "axe y"
		Vector3.AXIS_Z: return "axe z"
		_: return "axe ?"

# TODO rename
func _flatten_other_axis(vector: Vector3) -> Vector3:
	match abs(vector).max_axis_index():
		Vector3.AXIS_X:
			vector.y = 0
			vector.z = 0
		Vector3.AXIS_Y:
			vector.z = 0
			vector.x = 0
		Vector3.AXIS_Z:
			vector.y = 0
			vector.x = 0
	return vector.normalized()
