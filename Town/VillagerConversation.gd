extends ActorConversation

var got_letter = false

func get_persistent_data():
	var p = .get_persistent_data()
	p.merge({
		"got_letter": got_letter
	})
	return p

func load_persistent_data(p):
	.load_persistent_data(p)
	#got_letter = p.got_letter

var phrases = [
	"The kobolds took over the garrison!",
	"My boy is lost!",
	"The kobolds are going to take over the village!",
	"We are all doomed!"
]
func say_hello():
	if got_letter:
		say_bye("Thanks for the letter", 1)
	elif GameEngine.player.has_a_thing_in_group("letter-to-mom"):
		say_in_parts([
			"My boy was lost at the garrison.  I wish I had something to hold onto of his...",
			"Wait, can I see that letter?"
		])
	else:
		say_bye(phrases[randi()%phrases.size()], 2)

func player_said(_text, words):
	if words.has("yes"):
		GameEngine.player.add_xp(200)
		GameEngine.give_to_player("res://DandD/Potions/PotionOfHealing.tscn")
		say_bye("I can't believe he was thinking of his old Ma just before the end. Thank you so much for sharing the letter with me!\nI don't have much to reward you with other than this old potion that a like to nip on when I'm feeling down.", 2)
	elif words.has("no"):
		say_bye("You are horrible person!")
		GameEngine.player.lose_xp(300)
	elif words.has("bye"):
		say_bye("You aren't very nice to refuse to answer me.", 1)
		GameEngine.player.lose_xp(100)
