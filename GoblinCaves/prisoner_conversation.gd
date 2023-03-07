extends ActorConversation

var initiate_conversation = true
func say_hello(): say("Help!  You need to get us out of here before they eat us!!")
func say_bye(): say("Please, save us!", false)

func player_said(text:String, words:Array):
	if one_word_in(words, [ "key", "lock", "save", "help", "rescue" ]):
		say("The head jailer has the key, he doesn't come here very often though.")
	elif words.has("jailer"):
		say("The head jailer is a very large and mean goblin who doesn't feed us well.")
	elif one_word_in(words, [ "food", "feed" ]):
		say("They are feeding us disgusting moldy food.  But, at least they are feeding us.")
	elif (words.has("what") and words.has("happened")) or one_word_in(words, [ "capture", "captured", "why" ]):
		say([
			"A bunch of kobolds and goblins appeared inside the garrison in the middle of the night and knocked me out.",
			"I don't know how they got in there, but they certain had the element of surprise on us!"
		])
	else:
		super(text, words)

func wants_to_initiate_conversation():
	return initiate_conversation
	
func _process(_delta):
	if GameEngine.is_paused(): return
	if actor.is_hostile(): return
	if in_conversation and not actor.player_is_in_sight():
		end(0)
	elif not in_conversation and wants_to_initiate_conversation() and actor.player_is_in_sight() and actor.global_position.distance_to(GameEngine.player.global_position) < GameEngine.feet_to_pixels(3.5):
		initiate_conversation = false
		start()
