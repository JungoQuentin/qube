extends OmniLight3D

func _ready():
	_start_animation()

func _start_animation():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "light_energy", 0.5, 2)
	tween.tween_property(self, "light_energy", 2.0, 2)
	tween.tween_callback(_start_animation)
	tween.play()