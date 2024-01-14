extends Cube 
class_name HoleCube

var filled:= false

## If a cube is in, disable the collision
func fill():
	filled = true
	_collision_shape.disabled = true


func reset():
	filled = false
	_collision_shape.disabled = false
