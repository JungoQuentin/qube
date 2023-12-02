extends Node3D

@onready var level:= get_tree().current_scene

func _ready():
	await Utils.wait_while(func(): return level.map_cube == null)
	$WorldEnvironment.environment.background_color = Colors.background_color
	if Colors.inner_light_fade:
		$lights/inner.light_color = Colors.inner_light_color
		_start_inner_light_animation()

func _start_inner_light_animation():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($lights/inner, "light_energy", Colors.fade_from, Colors.fade_speed)
	tween.tween_property($lights/inner, "light_energy", Colors.fade_to,   Colors.fade_speed)
	tween.tween_callback(_start_inner_light_animation)
	tween.play()
