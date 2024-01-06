@tool
extends MovingCube 
class_name LaserCube

const LASER_HEIGHT = 20

@onready var laser: Laser = preload("res://src/levels/cubeTypes/Laser.tscn").instantiate()
@export var laser_on:= true:
	set(on):
		if laser != null:
			laser.visible = on
			laser.enabled = on
			if not laser_on and on:
				activate()
		laser_on = on
var just_changed:= false


func _ready():
	super._ready()
	add_child(laser)
	laser.position.y = 0.5
	laser_on = laser_on


func _process(_delta):
	if Engine.is_editor_hint():
		return
	laser.cylinder.height = LASER_HEIGHT
	if laser.is_colliding():
		var collider = laser.get_collider()
		if collider is Player:
			collider.laser_hit()
		else:
			var point = laser.get_collision_point()
			var dist = laser.global_position - point
			laser.cylinder.height = {
				Vector3.AXIS_X: abs(dist.x),
				Vector3.AXIS_Y: abs(dist.y),
				Vector3.AXIS_Z: abs(dist.z),
			}[abs(dist).max_axis_index()]
	laser.cylinder.position.y = laser.cylinder.height / 2


func activate():
	print("looong")


func player_start_move():
	if laser_on:
		laser_on = false
		just_changed = true


func player_end_move():
	if just_changed:
		just_changed = false
		return
	if not laser_on:
		laser_on = true
