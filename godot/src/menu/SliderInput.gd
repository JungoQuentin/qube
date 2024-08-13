@tool
extends VBoxContainer
class_name SliderInput

@export var setting_name: String
@export var step:= 1.0
@export var label: String:
	set(_label):
		$Label.text = _label
		label = _label
@export_range(1, 20) var _max: float
signal value_changed(int)

func _ready():
	$Label.text = label
	$Slider.step = step
	$Slider.min_value = 0.
	$Slider.max_value = _max
	if is_equal_approx(step, roundf(step)):
		$Slider.step = int(step)
	$Slider.value = Save.settings.get(setting_name)
	$Slider.value_changed.connect(func(v): value_changed.emit(v))
	focus_entered.connect(func(): $Slider.grab_focus())
