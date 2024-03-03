extends Node

## Wait that the condition function returns false
func wait_while(condition: Callable, timeout=5, frequency=0.01) -> bool:
	var passed = 0.0
	while condition.call():
		if passed > timeout: return false
		passed += frequency
		await get_tree().create_timer(frequency).timeout
	return true

## Returns the first collider found by a raycast
func get_raycast_collider(parent: Node3D, _position: Vector3, _target_position: Vector3) -> Node:
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

## Change the parent of a node and keep the global transform if keep_global is true
func switch_parent(node: Node, new_parent, keep_global=false):
	if not node.is_inside_tree():
		return
	var g = node.global_transform
	var old_parent = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)
	if keep_global:
		node.global_transform = g
	return old_parent

## Returns the first pressed action in the array. If none is pressed, returns an empty string
func is_one_action_pressed(actions: Array[String]) -> String:
	for action in actions:
		if Input.is_action_pressed(action):
			return action
	return ""

func are_tests_running() -> bool:
	return get_tree().get_current_scene().name == "GutRunner"

func sleep(seconds: float):
	await get_tree().create_timer(seconds).timeout

func run_after_sleep(seconds: float, callback: Callable):
	await sleep(seconds)
	callback.call()

## from an array, create a dictionary where the key is the element of the array and the value, what you did with the predicate
func arr_to_dict(array: Array, predicate: Callable):
	var dict = {}
	for el in array:
		dict[el] = predicate.call(el)
	return dict

## 
func crash(message = ""):
	printerr(message)
	for s in get_stack():
		printerr(s)
	printerr("=== quiting ===")
	get_tree().quit()

## Crash when a function is not implemented
func unimplemented(message = ""):
	crash("not implemented: " + message)
