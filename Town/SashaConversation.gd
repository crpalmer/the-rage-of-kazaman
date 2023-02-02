extends ConversationalActor

const QUEST_GOBLINS = 1

var first_conversation = true
var waiting_for_yes_for = 0
var accepted_quests = 0
var completed_quests = 0

const accept_quest = "Are you brave enough to go investigate?"

const goblins_quest = [
		"Hi Flash.  It looks like you had the same crazy dream I had about Goblins.They were taking over an old abandoned castle over to the East of your house",
		"Hmmmm.  Do you think maybe it wasn't a dream???"
	]

func wants_to_initiate_conversation():
	return first_conversation
	
func get_persistent_data():
	return {
		"waiting_for_yes_for": waiting_for_yes_for,
		"accepted_quests": accepted_quests,
		"completed_quests": completed_quests
	}

func load_persistent_data(p):
	waiting_for_yes_for = p.waiting_for_yes_for
	accepted_quests = p.accepted_quests
	completed_quests = p.completed_quests
	first_conversation = false

func say_hello():
	if first_conversation:
		first_conversation = false
		propose_quest(QUEST_GOBLINS, goblins_quest)
	else:
		say("Hi Flash.  What's up?")

func player_said(what, words):
	if waiting_for_yes_for != 0:
		if words.has("yes"):
			accepted_quests |= waiting_for_yes_for
			waiting_for_yes_for = 0
			say("You're the best flash, you can do it!")
		elif words.has("no"):
			say("Sorry to hear that flash, it was sounded like a super brave adventure...")
			GameEngine.player.died()
		else:
			say("Yes or no, will you help?")
	else:
		if words.has("quest") or words.has("quests"):
			say_incomplete_quests()
		.player_said(what, words)

func propose_quest(quest, text_parts):
	text_parts.push_back(accept_quest)
	say_in_parts(text_parts)
	waiting_for_yes_for = quest

func say_incomplete_quests():
	var quests = []
	if quest_is_incomplete(QUEST_GOBLINS): quests.append_array(goblins_quest)
	if quests.size() > 0:
		say_in_parts(quests)
	else:
		say("You're finished all your quests!")

func quest_is_incomplete(q):
	return accepted_quests & q == q and completed_quests & q == 0
