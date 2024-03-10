extends Node3D

@onready var _level:= get_tree().current_scene
@onready var _color_set = _level.color_set
@onready var world_env: WorldEnvironment = $WorldEnvironment

func _ready():
	world_env.environment.background_color = _color_set.background_color
	world_env.environment.adjustment_enabled = true
	world_env.environment.adjustment_saturation = _color_set.saturation
	
	if _color_set.inner_light_fade:
		$lights/inner.light_color = _color_set.inner_light_color
		_start_inner_light_animation()

func _start_inner_light_animation():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($lights/inner, "light_energy", _color_set.fade_from, _color_set.fade_speed)
	tween.tween_property($lights/inner, "light_energy", _color_set.fade_to,   _color_set.fade_speed)
	tween.tween_callback(_start_inner_light_animation)
	tween.play()
