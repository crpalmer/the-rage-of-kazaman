extends CanvasLayer

func message(text):
	GameEngine.pause()
	$Text.text = text
	show()
	yield($Close, "pressed")
	hide()
	GameEngine.resume()
