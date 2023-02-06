extends ConversationalActor

const QUEST_KOBOLDS = 1

var available_quests = QUEST_KOBOLDS
var accepted_quests = 0
var completed_quests = 0

var waiting_for_yes_for = QUEST_KOBOLDS

const accept_quest = "Will you accept the mission?"

const kobolds_quest = [
		"Have you heard the horrible news?",
		"The eastern garrison was attacked by Kobolds this morning.  Early reports indicate that the guards were all killed or taken prisoner and that the kobolds are now occupying the garrison.",
		"I need a brave adventurer to investigate and report back to me."
	]

func wants_to_initiate_conversation():
	return available_quests != 0
	
func get_persistent_data():
	return {
		"available_quests": available_quests,
		"waiting_for_yes_for": waiting_for_yes_for,
		"accepted_quests": accepted_quests,
		"completed_quests": completed_quests
	}

func load_persistent_data(p):
	available_quests = p.available_quests
	waiting_for_yes_for = p.waiting_for_yes_for
	accepted_quests = p.accepted_quests
	completed_quests = p.completed_quests

func say_hello():
	if waiting_for_yes_for != 0:
		propose_first_available_quest()
	else:
		say("What's up?")

func player_said(what, words):
	if waiting_for_yes_for != 0:
		if words.has("yes"):
			accepted_quests |= waiting_for_yes_for
			available_quests &= ~waiting_for_yes_for
			waiting_for_yes_for = 0
			say("Thank you.  The town appreciates your valor.")
		elif words.has("no"):
			waiting_for_yes_for = 0
			say_bye("Sorry to hear that you're too afraid to help.", 1)
		else:
			say("Yes or no, will you help?")
	else:
		if words.has("quest") or words.has("quests"):
			if available_quests != 0: propose_first_available_quest()
			else: say_incomplete_quests()
		elif words.has("kobold") or words.has("kobolds"):
			say("The kobolds are occupying the east garrison.  Follow the main road leading east out of town.")
		else:
			.player_said(what, words)

func propose_first_available_quest():
	if quest_is_available(QUEST_KOBOLDS): propose_quest(QUEST_KOBOLDS, kobolds_quest)

func propose_quest(quest, text_parts):
	var text_and_question = text_parts.duplicate()
	text_and_question.push_back(accept_quest)
	say_in_parts(text_and_question)
	waiting_for_yes_for = quest

func say_incomplete_quests():
	var quests = []
	if quest_is_incomplete(QUEST_KOBOLDS): quests.append_array(kobolds_quest)
	if quests.size() > 0:
		say_in_parts(quests)
	else:
		say("You've finished all your quests!")

func quest_is_incomplete(q):
	return accepted_quests & q == q and completed_quests & q == 0

func quest_is_available(q):
	return available_quests & q == q
