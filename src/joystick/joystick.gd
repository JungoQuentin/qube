extends Area2D
class_name Joystick

@onready var big = $big
@onready var small = $big/small
@onready var distance = $radius.shape.radius
var is_touching = false


func _ready():
	big.hide()

# Debug
@onready var _start_label_pos = $Label.global_position
var _dbg_count = 0

func _input(event):
	if not event is InputEventScreenTouch:# and not event is InputEventMouseButton:
		return
	_dbg_count += 1
	$Label.text = str(_dbg_count)
	global_position = get_global_mouse_position()
	$Label.global_position = _start_label_pos
	_stop_showing() if is_touching else	_start_showing()

func _stop_showing():
	big.hide()
	small.position = Vector2(0, 0)
	is_touching = false

func _start_showing():
	big.show()
	is_touching = true

func _process(_delta):
	if not is_touching:
		return
	small.global_position = get_global_mouse_position()
	if small.position.distance_to(big.position ) > distance:
		small.position = (small.position - big.position).normalized() * distance

func get_x_input():
	return (roundf((small.position - big.position).normalized().x))

func get_y_input():
	return (roundf((small.position - big.position).normalized().y))

func get_string_direction():
	if get_x_input() == 1:
		return "right"
	if get_x_input() == -1:
		return "left"
	if get_y_input() == 1:
		return "bottom"
	if get_y_input() == -1:
		return "top"
	return ""
