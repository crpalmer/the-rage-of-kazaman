extends Label

func _process(_delta: float) -> void:
	set_text("FPS %.0f" % Engine.get_frames_per_second())
