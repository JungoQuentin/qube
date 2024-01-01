@tool
extends Cube 
class_name LaserCube

@onready var laser: Laser = preload("res://src/levels/cubeTypes/Laser.tscn").instantiate()


func _ready():
	super._ready()
	add_child(laser)
