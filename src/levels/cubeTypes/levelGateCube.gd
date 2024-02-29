extends EndCube 
class_name LevelGateCube

@export var destination: PackedScene
@export var dependency: PackedScene


func _ready():
	super._ready()
	is_gate_open()


func is_gate_open() -> bool:
	if dependency == null:
		update_color(true)
		return true
	var is_open = LevelManager.is_level_finished(dependency) or LevelManager.get_current_progression().all_puzzle_unlocked
	update_color(is_open)
	return is_open
