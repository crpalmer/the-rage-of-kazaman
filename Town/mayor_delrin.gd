extends ActorConversation

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

func get_persistent_data():
	return {
		"available_quests": available_quests,
		"waiting_for_yes_for": waiting_for_yes_for,
		"accepted_quests": accepted_quests,
		"completed_quests": completed_quests
	}

func load_persistent_data(p):
	super.load_persistent_data(p)
	available_quests = p.available_quests
	waiting_for_yes_for = p.waiting_for_yes_for
	accepted_quests = p.accepted_quests
	completed_quests = p.completed_quests

func _ready():
	super()
	add_to_group("PersistentNodes")

func wants_to_initiate_conversation():
	return available_quests != 0

func say_hello():
	if waiting_for_yes_for != 0:
		propose_first_available_quest()
	elif not quest_is_accepted(QUEST_KOBOLD_NOTE) and GameEngine.player.has_a("kobold note"):
		accept_quest(QUEST_KOBOLD_NOTE)
		GameEngine.message("You show the mayor the kobold note.", true)
		await say([
			"Oh, that note is very interesting.  The kobolds sound like an organized group.  Please investigate the Garrison and see if you can find out who's behind it all.",
			"Take another potion of healing to help you survive back in the wilderness."
		])
		GameEngine.player.add_xp(100)
		GameEngine.give_to_player("res://DandD/Potions/potion_of_healing.tscn")
	elif not quest_is_accepted(QUEST_KOBOLDS_DIE) and GameEngine.has_completed_milestone("found-eastern-garrison"):
		accept_quest(QUEST_KOBOLDS_DIE)
		GameEngine.message("You tell the mayor about the kobolds and their military demeanor.", true)
		say([
			"These kobolds must be trying to muster an army to invade the village.  You must enter the Garrison and eradicate the threat!",
			"Take this magic sword and helmet to help you in your battles."
		])
		GameEngine.give_to_player("res://DandD/Armor/helmet_plus_1.tscn")
		GameEngine.give_to_player("res://DandD/Weapons/long_sword_plus_1.tscn")
	elif GameEngine.has_completed_milestone("explored-garrison") and not GameEngine.has_completed_milestone("sent-into-the-tunnels"):
		GameEngine.message("You tell the major about the Kobold Warrior and the tunnel that the kobolds dug.")
		say("Our brave garrison members must be kobold prisoners.  You must return to the Garrison and search the tunnels for the garrison team.")
		GameEngine.player.add_xp(500)
		GameEngine.complete_milestone("sent-into-the-tunnels")
	else:
		say("What's up?")

func player_said(what, words):
	if waiting_for_yes_for != 0:
		if words.has("yes"):
			accepted_quests |= waiting_for_yes_for
			available_quests &= ~waiting_for_yes_for
			waiting_for_yes_for = 0
			await say([
				"Thank you.\nTravel East from the main gates.  The Garrison is checked the other side of the river.\nTake this potion of healing to help you in the wilderness.",
				"Please investigate and report back checked what you find."
			])
			GameEngine.give_to_player("res://DandD/Potions/potion_of_healing.tscn")
		elif words.has("no"):
			waiting_for_yes_for = 0
			say_and_end("Sorry to hear that you're too afraid to help.", 1)
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
			super.player_said(what, words)

func propose_first_available_quest():
	if quest_is_available(QUEST_KOBOLDS): propose_quest(QUEST_KOBOLDS, kobolds_quest)

func propose_quest(quest, text_parts):
	var text_and_question = text_parts.duplicate()
	text_and_question.push_back(accept_quest_text)
	say(text_and_question)
	waiting_for_yes_for = quest

func say_incomplete_quests():
	var quests = []
	if quest_is_incomplete(QUEST_KOBOLDS): quests.append_array(kobolds_quest)
	if quest_is_incomplete(QUEST_KOBOLD_NOTE): quests.append("Investigate the source of the kobold note and find out who or what is in charge of the Garrison.")
	if quests.size() > 0:
		say(quests)
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
