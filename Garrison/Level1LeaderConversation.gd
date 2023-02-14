extends ActorConversation

var initiate_conversation = true
var bad_answers = 0

onready var transport = actor.get_node("../LeaderTransportPoint")

func get_persistent_data():
	return {
		"bad_answers": bad_answers,
		"initiate_conversation": initiate_conversation
	}

func load_persistent_data(p):
	bad_answers = p.bad_answers
	initiate_conversation = p.initiate_conversation

func _ready():
	add_to_group("PersistentNodes")

func wants_to_initiate_conversation():
	return initiate_conversation

func say_hello():
	say("What the @#$!%*&@ are you doing in my Garrison???")
	initiate_conversation = false

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
	GameEngine.spawn_near_player("res://DandD/Monsters/Kobold.tscn", n)
