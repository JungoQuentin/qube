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
