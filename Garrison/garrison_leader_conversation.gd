extends ActorConversation

var bad_answers = 0
var  teleported = false

var transport

func get_persistent_data():
	return {
		"bad_answers": bad_answers,
		"teleported": teleported
	}

func load_persistent_data(p):
	bad_answers = p.bad_answers
	teleported = p.teleported

func _ready():
	super()
	transport = actor.get_node("../LeaderTransportPoint")
	add_to_group("PersistentNodes")

func wants_to_initiate_conversation():
	return true

func say_hello():
	if not teleported:
		say("What the @#$!%*&@ are you doing in my Garrison???")
	else:
		await say_and_end("You really wish to be killed don't you?  I guess I'll do it myself if my guards can't handle it.", 2)
		actor.make_hostile()
		teleported = false

func finish(text, n_guards, xp = 0):
	await say_and_end(text)
	if xp > 0: GameEngine.player.add_xp(xp)
	if n_guards > 0: spawn_guards(n_guards)

func player_said(_text, words):
	if words.has("fuck") and words.has("off"):
		finish("Well, that is a very stupid attitude.  Destroy the rude intruder!", 8)
	elif words.has("work"):
		finish("You think I would believe a smelly human would work for me?  Ha!  Die you pathetic fool!", 4)
	elif (words.has("walk") or words.has("walked")) and words.has("bar"):
		finish("Funny joke.  But, now you must die.", 1, 50)
	elif words.has("inspection") or words.has("inspect"):
		finish("Oh, Vintar sent you?  Please look around, you'll find everything is in good shape.", 0, 100)
	elif one_word_in(words, [ "wander", "wandered", "accident", "accidentally", "mistake", "lost"]):
		finish("Seriously?   You expect me to believe that crazy story??", 3)
	elif words.has("bye"):
		finish("Now, that's just rude.  Not even being civil and answering a question?  Guards!", 4)
	else:
		say("That doesn't sound entirely believable.")
		bad_answers += 1
		if bad_answers >= 4:
			finish("I think you're trying to trick me.  Guards!", 2)

func spawn_guards(n):
	transport.teleport(actor)
	teleported = true
	GameEngine.spawn_near_player("res://DandD/Monsters/kobold.tscn", n)
