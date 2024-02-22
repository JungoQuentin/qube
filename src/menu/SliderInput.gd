@tool
extends VBoxContainer
class_name SliderInput

@export var setting_name: String
@export var label: String:
	set(_label):
		$Label.text = _label
		label = _label
@export_range(3, 20) var _max: int

func _ready():
	$Label.text = label
	$Slider.min_value = 0
	$Slider.max_value = _max
	$Slider.value = Save.settings.get(setting_name)
	$Slider.value_changed.connect(set_value)
	focus_entered.connect(func(): $Slider.grab_focus())


func set_value(new_value):
	Save.settings.set(setting_name, new_value)
	Save.save()
