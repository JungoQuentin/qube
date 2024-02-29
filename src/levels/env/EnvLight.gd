extends Node3D

@onready var level:= get_tree().current_scene

func _ready():
	await Utils.wait_while(func(): return level.map_cube == null)
	$WorldEnvironment.environment.background_color = Colors._color_set.background_color
	if Colors._color_set.inner_light_fade:
		$lights/inner.light_color = Colors._color_set.inner_light_color
		_start_inner_light_animation()

func _start_inner_light_animation():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($lights/inner, "light_energy", Colors._color_set.fade_from, Colors._color_set.fade_speed)
	tween.tween_property($lights/inner, "light_energy", Colors._color_set.fade_to,   Colors._color_set.fade_speed)
	tween.tween_callback(_start_inner_light_animation)
	tween.play()
