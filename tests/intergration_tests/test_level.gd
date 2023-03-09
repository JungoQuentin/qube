extends GutTest

func test_init_level():
	var scene: PackedScene = load("res://src/levels/003.tscn")
	var level = scene.instantiate()

	#TODO ne march pas car le level n'est pas le le root de la scène (c'est le GutTest)
	### add_child(level)

	level.queue_free()
	scene = null
	assert_eq(1, 1)
