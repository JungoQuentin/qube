@tool
extends MovingCube 
class_name LaserCube

@onready var laser: Laser = preload("res://src/levels/cubeTypes/Laser.tscn").instantiate()


func _ready():
	super._ready()
	add_child(laser)


func _physics_process(delta):
	if laser.is_colliding():
		var collider = laser.get_collider()
		if collider is Player:
			collider.laser_hit()

