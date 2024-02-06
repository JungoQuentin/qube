@tool
extends HBoxContainer
class_name SliderInput

@export var label: String:
	set(_label):
		$Label.text = _label
		label = _label
@export_range(3, 20) var max: int

func _ready():
	$Label.text = label
	$Slider.min_value = 1
	$Slider.max_value = max
	focus_entered.connect(func(): $Slider.grab_focus())
