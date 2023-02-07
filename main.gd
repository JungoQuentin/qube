extends Node3D

func _ready():
	_start_animation()

func _start_animation():
	var tween = create_tween()
	tween.tween_property($"lights/InnerLight", "light_energy", 0.1, 2)
	tween.tween_property($"lights/InnerLight", "light_energy", 2, 2.5)
	tween.tween_callback(_start_animation)
	tween.play()