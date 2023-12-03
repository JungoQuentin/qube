extends Cube 
class_name StartCube

func _ready():
	get_tree().current_scene.startCube = self
	super._ready()
