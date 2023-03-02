extends ActorConversation

func _ready():
	services_for_sale = [
		{ "name": "cure light wounds", "cost": 10.23 },
		{ "name": "cure serious wounds", "cost": 50.01 },
		{ "name": "cure poison", "cost":100.5}
	]

func say_hello():
	say("I am Druid Telgrave.  I live in nature and nature gives back to me by letting me help injured people who visit me.")

func player_said(text, words):
	if words.has("nature"):
		say("Nature is beautiful and part of that beauty is it's ability to heal")
	elif words.has("heal"):
		say("Yes, I offer healing services")
	elif words.has("name"):
		say_hello()
	else:
		super.player_said(text, words)

func is_sale_utterance(text, words):
	if words.has("spells") or words.has("healing") or words.has("services"): return true
	return super.is_sale_utterance(text, words)

func heal(dice):
	var hp = GameEngine.roll(dice)
	GameEngine.player.give_hit_points(hp)
	return "You are healed %d hit points." % hp

func sell_service(sale):
	if sale.name == "cure light wounds": return heal(GameEngine.Dice(1, 8, +4))
	elif sale.name == "cure serious wounds": return heal(GameEngine.Dice(3, 8, +4))
	elif sale.name == "cure poison": return "You are all better now"
	return "FAILED TO FIND SELLING ITEM"
