extends Cube

func _ready():
	super._ready()
	initial_color = Global.normal_init_color
	touched_color = Global.normal_touched_color
	mesh.surface_get_material(0).albedo_color = initial_color

func on_touch():
	super.on_touch()
	# TODO improve ! (lauch the good node instead of all...)
	var n = randi_range(0, 7)
	$Music.get_child(n).play()
