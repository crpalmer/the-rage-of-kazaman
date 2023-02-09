extends Node2D

export(String, MULTILINE) var message
export(bool) var show_once = true
export(String) var grants_milestone

onready var canvas_layer = $CanvasLayer
onready var text = $CanvasLayer/Text
onready var close = $CanvasLayer/Close

var may_show = true

func should_show():
	return may_show

func on_shown():
	if show_once: may_show = false
	if grants_milestone != "": GameEngine.complete_milestone(grants_milestone)
	
func _ready():
	canvas_layer.visible = false
	for c in get_children():
		if c is Area2D:
			c.connect("body_entered", self, "body_entered")

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
