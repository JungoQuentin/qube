extends Cube

func on_touch():
	super.on_touch()
	# TODO improve ! (lauch the good node instead of all...)
	var n = randi_range(0, 7)
	$Music.get_child(n).play()