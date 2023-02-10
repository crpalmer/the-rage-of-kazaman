extends Node2D

export(String, MULTILINE) var message
export(bool) var show_once = true
export(String) var grants_milestone

onready var canvas_layer = $CanvasLayer
onready var text = $CanvasLayer/Text
onready var close = $CanvasLayer/Close

var may_show = true

func get_persistent_data():
	return {
		"may_show": may_show
	}

func load_persistent_data(p):
	may_show = p.may_show

func _ready():
	add_to_group("PersistentNodes")
	yield(get_tree(), "idle_frame")
	canvas_layer.visible = false
	for c in get_children():
		if c is Area2D:
			c.connect("body_entered", self, "body_entered")

func should_show():
	return may_show

func on_shown():
	if show_once: may_show = false
	if grants_milestone != "": GameEngine.complete_milestone(grants_milestone)
	

func body_entered(body):
	if body == GameEngine.player and should_show():
		on_shown()
		call_deferred("show_message")

func show_message():
	GameEngine.pause()
	text.text = message
	canvas_layer.visible = true
	yield(close, "pressed")
	canvas_layer.visible = false
	GameEngine.resume()
