extends ConversationalActor

const QUEST_KOBOLDS = 1
const QUEST_KOBOLD_NOTE = 2
const QUEST_KOBOLDS_DIE = 4

var available_quests = QUEST_KOBOLDS
var accepted_quests = 0
var completed_quests = 0

var waiting_for_yes_for = QUEST_KOBOLDS

const accept_quest_text = "Will you accept the mission?"

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
	print_debug("Accepted: ", quest_is_accepted(QUEST_KOBOLD_NOTE), " has: ", GameEngine.player.has_a("kobold note"))
	if waiting_for_yes_for != 0:
		propose_first_available_quest()
	elif not quest_is_accepted(QUEST_KOBOLD_NOTE) and GameEngine.player.has_a("kobold note"):
		accept_quest(QUEST_KOBOLD_NOTE)
		GameEngine.message("You show the mayor the kobold note.")
		GameEngine.player.add_xp(100)
		say("Oh, that note is very interesting.  The kobolds sound like an organized group.  Please investigate the Garrison and see if you can find out who's behind it all.")
	elif not quest_is_accepted(QUEST_KOBOLDS_DIE) and GameEngine.has_completed_milestone("found-eastern-garrison"):
		accept_quest(QUEST_KOBOLDS_DIE)
		GameEngine.message("You tell the mayor about the kobolds and their military demeanor.")
		say_in_parts([
			"These kobolds must be trying to muster an army to invade the village.  You must enter the Garrison and eradicate the threat!",
			"Take this magic sword and helmet to help you in your battles."
		])
		GameEngine.player.add_to_inventory(load("res://DandD/Armor/HelmetPlus1.tscn").instance())
		GameEngine.player.add_to_inventory(load("res://DandD/Weapons/LongSwordPlus1.tscn").instance())
	else:
		say("What's up?")

func player_said(what, words):
	if waiting_for_yes_for != 0:
		if words.has("yes"):
			accepted_quests |= waiting_for_yes_for
			available_quests &= ~waiting_for_yes_for
			waiting_for_yes_for = 0
			say("Thank you.  Travel East from the main gates.  The Garrison is on the other side of the river.  Please investigate and report back on what you find.")
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
			if quest_is_incomplete(QUEST_KOBOLD_NOTE):
				say("Find out who is behind the kobold attack of the Garrison.")
			elif quest_is_incomplete(QUEST_KOBOLDS):
				say("The kobolds are occupying the east Garrison.  Follow the main road leading east out of town and report back to me.")
			else:
				say("Thanks again for removing the kobold threat.")
		else:
			.player_said(what, words)

func propose_first_available_quest():
	if quest_is_available(QUEST_KOBOLDS): propose_quest(QUEST_KOBOLDS, kobolds_quest)

func propose_quest(quest, text_parts):
	var text_and_question = text_parts.duplicate()
	text_and_question.push_back(accept_quest_text)
	say_in_parts(text_and_question)
	waiting_for_yes_for = quest

func say_incomplete_quests():
	var quests = []
	if quest_is_incomplete(QUEST_KOBOLDS): quests.append_array(kobolds_quest)
	if quest_is_incomplete(QUEST_KOBOLD_NOTE): quests.append("Investigate the source of the kobold note and find out who or what is in charge of the Garrison.")
	if quests.size() > 0:
		say_in_parts(quests)
	else:
		say("You've finished all your quests!")

func quest_is_accepted(q):
	return (accepted_quests & q) == q

func accept_quest(q):
	accepted_quests |= q

func quest_completed(q):
	completed_quests |= q

func quest_is_complete(q):
	return (completed_quests & q) == q

func quest_is_incomplete(q):
	return accepted_quests & q == q and completed_quests & q == 0

func quest_is_available(q):
	return available_quests & q == q
