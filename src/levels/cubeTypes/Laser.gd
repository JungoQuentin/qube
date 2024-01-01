extends RayCast3D
class_name Laser


func _physics_process(delta):
	if is_colliding():
		var collider = get_collider()
		if collider is Player:
			collider.laser_hit()
