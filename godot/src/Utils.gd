class_name Utils

## Get the main loop as scene tree
## This avoid declaring this script as an autoload
static func tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree

## Wait that the condition function returns false
static func wait_while(condition: Callable, timeout=5, frequency=0.01) -> bool:
	var passed = 0.0
	while condition.call():
		if passed > timeout: return false
		passed += frequency
		await Utils.tree().create_timer(frequency).timeout
	return true

## Returns the first collider found by a raycast
static func get_raycast_collider(parent: Node3D, _position: Vector3, _target_position: Vector3) -> Node:
	var new_raycast = RayCast3D.new()
	parent.add_child(new_raycast)
	new_raycast.exclude_parent = true
	new_raycast.target_position = _target_position
	new_raycast.position = _position
	new_raycast.enabled = true
	new_raycast.force_raycast_update()
	var collider = new_raycast.get_collider()
	new_raycast.queue_free()
	return collider

## Returns the first pressed action in the array. If none is pressed, returns an empty string
static func is_one_action_pressed(actions: Array[String]) -> String:
	for action in actions:
		if Input.is_action_pressed(action):
			return action
	return ""

## Check if we are in a GutRunner test
static func are_tests_running() -> bool:
	return Utils.tree().get_current_scene().name == "GutRunner"

## await seconds
static func sleep(seconds: float):
	await Utils.tree().create_timer(seconds).timeout

## call a Callable after sleeping seconds
static func run_after_sleep(seconds: float, callback: Callable):
	await sleep(seconds)
	callback.call()

## from an array, create a dictionary where the key is the element of the array and the value, what you did with the predicate
static func arr_to_dict(array: Array, predicate_value: Callable, predicate_key: Callable = func(k): return k):
	var dict = {}
	for el in array:
		var key = predicate_key.call(el)
		dict[key] = predicate_value.call(el)
	return dict
