extends Cube

@onready var blockingCubePreload = preload("res://src/MapCube/cubeTypes/blockingCube.tscn")

func on_leave():
	super.on_leave()
	var blockingCube = blockingCubePreload.instantiate()
	get_parent().add_child(blockingCube)
	blockingCube.position = position
	self.queue_free()