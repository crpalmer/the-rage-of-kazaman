extends ConversationalActor

func _ready():
	things_for_sale = []
	for c in get_children():
		if c is InventoryThing: things_for_sale.push_back(c)

func say_hello():
	say("I am Blacksmith.  What do you want?")

func player_said(text, words):
	if words.has("blacksmith"):
		say("I make weapons and armor")
	elif words.has("kobold") or words.has("kobolds"):
		say("I hear that they took over the eastern garrison.  Sad news.  Those guys were good customers.")
	elif words.has("name"):
		say_hello()
	else:
		.player_said(text, words)

func is_sale_utterance(text, words):
	if words.has("weapons") or words.has("armor") or words.has("goods"): return true
	return .is_sale_utterance(text, words)

func sell_thing(thing):
	GameEngine.player.add_to_inventory(thing)
	return "You acquired: " + thing.display_name
