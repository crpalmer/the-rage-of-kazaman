extends ActorConversation

var bad_answers = 0
var  teleported = false

onready var transport = actor.get_node("../LeaderTransportPoint")

func get_persistent_data():
	return {
		"bad_answers": bad_answers,
		"teleported": teleported
	}

func load_persistent_data(p):
	bad_answers = p.bad_answers
	teleported = p.teleported

func _ready():
	add_to_group("PersistentNodes")

func wants_to_initiate_conversation():
	return true

func say_hello():
	if not teleported:
		say("What the @#$!%*&@ are you doing in my Garrison???")
	else:
		say_bye("You really wish to be killed don't you?  I guess I'll do it myself if my guards can't handle it.", 2)
		actor.make_hostile()
		teleported = false

func player_said(_text, words):
	if (words.has("walk") or words.has("walked")) and words.has("bar"):
		say_bye("Funny joke.  But, now you must die.", 1)
		GameEngine.player.add_xp(50)
		spawn_guards(1)
	elif words.has("inspection") or words.has("inspect"):
		say_bye("Oh, Vintar sent you?  Please look around, you'll find everything is in good shape.", 1)
		GameEngine.player.add_xp(100)
	elif one_word_in(words, [ "wander", "wandered", "accident", "accidentally", "mistake", "lost"]):
		say_bye("Seriously?   You expect me to believe that crazy story??")
		spawn_guards(3)
	elif words.has("bye"):
		say_bye("Now, that's just rude.  Not even being civil and answering a question?  Guards!")
		spawn_guards(4)
	else:
		say("That doesn't sound entirely believable.")
		bad_answers += 1
		if bad_answers >= 5:
			say_bye("I think you're trying to trick me.  Guards!", 1)
			spawn_guards(2)

func spawn_guards(n):
	transport.teleport(actor)
	teleported = true
	GameEngine.spawn_near_player("res://DandD/Monsters/Kobold.tscn", n)
