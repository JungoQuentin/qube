extends Cube 
class_name EndCube


func on_touch():
	super.on_touch()
	LevelManager.goto_next_level()
