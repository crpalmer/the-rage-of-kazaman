extends ConversationalActor

var is_selling = false
var for_sale = [
	{ "name": "cure light wounds", "cost": 10.23 },
	{ "name": "cure serious wounds", "cost": 50.01 },
	{ "name": "cure poison", "cost":100.5}
]

func is_sale_utterance(text, words):
	return words.has("buy") or words.has("services") or words.has("spells") or words.has("healing")

func process_sale(text):
	for sale in for_sale:
		if sale.name == text:
			if GameEngine.player.try_to_pay(sale.cost):
				say(sell(sale) + "\nYou paid %s.  What else can I help you with?" % GameEngine.currency_value_to_string(sale.cost))
			else:
				say("You can't afford %s" % GameEngine.currency_value_to_string(sale.cost))
			is_selling = false
			return true
	return false

func heal(dice):
	var hp = GameEngine.roll(dice)
	GameEngine.player.give_hit_points(hp)
	return "You are healed %d hit points." % hp

func sell(sale):
	if sale.name == "cure light wounds": return heal(GameEngine.Dice(1, 8, +4))
	elif sale.name == "cure serious wounds": return heal(GameEngine.Dice(3, 8, +4))
	elif sale.name == "cure poison": return "You are all better now"
	return "FAILED TO FIND SELLING ITEM"

func say_hello():
	say("I am Druid Telgrave.  I live in nature and nature gives back to me by letting me help injured people who visit me.")

func player_said(text, words):
	if process_sale(text):
		# Someone already knows what we're selling, them have it
		pass
	elif is_selling:
		handle_selling_other_than_sale(text, words)
	elif for_sale.size() > 0 and is_sale_utterance(text, words):
		start_selling()
	elif words.has("nature"):
		say("Nature is beautiful and part of that beauty is it's ability to heal")
	elif words.has("heal"):
		say("Yes, I offer healing services")
	elif words.has("name"):
		say_hello()
	else:
		.player_said(text, words)

func start_selling():
	is_selling = true
	var text = ""
	var divider = ""
	for sale in for_sale:
		text = text + "%s%s for %s" % [divider, sale.name, GameEngine.currency_value_to_string(sale.cost)]
		divider = " or "
	say("I can offer: " + text)

func handle_selling_other_than_sale(text, words):
	if text == "" or text == "" or words.has("nothing") or words.has("none"):
		say("What else can I help you with then?")
		is_selling = false
	elif is_sale_utterance(text, words):
		start_selling()
