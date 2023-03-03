extends Node

func wait_while(condition: Callable, timeout=5, frequency=0.01) -> bool:
	var passed = 0.0
	while condition.call():
		if passed > timeout: return false
		passed += frequency
		await get_tree().create_timer(frequency).timeout
	return true

func get_raycast_collider(parent, _position: Vector3, _target_position: Vector3) -> Node:
	var new_raycast = RayCast3D.new()
	parent.add_child(new_raycast)
	new_raycast.target_position = _target_position
	new_raycast.position = _position
	new_raycast.enabled = true
	new_raycast.force_raycast_update()
	var collider = new_raycast.get_collider()
	new_raycast.queue_free()
	return collider

func switch_parent(node, new_parent, keep_global=false):
	var g = node.global_transform
	var old_parent = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)
	if keep_global:
		node.global_transform = g
	return old_parent

func is_one_action_pressed(actions: Array[String]) -> String:
	for action in actions:
		if Input.is_action_pressed(action):
			return action
	return ""