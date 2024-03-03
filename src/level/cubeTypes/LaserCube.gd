@tool
extends MovingCube 
class_name LaserCube

const LASER_HEIGHT = 20

@onready var laser: Laser = preload("res://src/level/cubeTypes/Laser.tscn").instantiate()
@export var laser_on:= true:
	set(on):
		if laser != null:
			laser.visible = on
			if not laser_on and on:
				activate()
			else:
				if _tween != null and _tween.is_valid():
					_tween.kill()
		laser_on = on
var _just_changed:= false
var _tween: Tween


func _ready():
	super._ready()
	add_child(laser)
	laser.position.y = 0.5
	laser_on = laser_on
	laser.enabled = true
	(get_tree().current_scene as BaseLevel).player.start_move.connect(_on_player_start_move)
	(get_tree().current_scene as BaseLevel).player.end_move.connect(_on_player_end_move)


func activate():
	if Engine.is_editor_hint():
		return
	
	laser.cylinder.height = 0
	laser.cylinder.position = Vector3.ZERO
	var goal_height = LASER_HEIGHT
	
	if laser.is_colliding():
		var collider = laser.get_collider()
		if collider is Player:
			collider.laser_hit()
		else:
			var point = laser.get_collision_point()
			var dist = laser.global_position - point
			goal_height = {
				Vector3.AXIS_X: abs(dist.x),
				Vector3.AXIS_Y: abs(dist.y),
				Vector3.AXIS_Z: abs(dist.z),
			}[abs(dist).max_axis_index()]
	var goal_position = Vector3.UP * goal_height / 2.
	
	var time = goal_height / 20.
	_tween = create_tween().set_parallel()
	_tween.tween_property(laser.cylinder, "height", goal_height, time)
	_tween.tween_property(laser.cylinder, "position", goal_position, time)
	await _tween.finished


func _on_player_start_move():
	if laser_on:
		laser_on = false
		_just_changed = true


func _on_player_end_move():
	if _just_changed:
		_just_changed = false
		return
	if not laser_on:
		laser_on = true


func is_collinding_with(node: Node3D) -> bool:
	return laser_on and node == laser.get_collider()
