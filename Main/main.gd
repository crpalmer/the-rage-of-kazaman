extends Node2D

var game_in_progress = false
var fighter

@export var debugging_startup = true
@onready var splash = $Splash
@onready var splash_timer = $Splash/Timer
@onready var splash_music = $Splash/Music
@onready var hud = $HUD
@onready var main_menu = $MainMenu
@onready var save = $MainMenu/Save
@onready var died = $Died
@onready var died_timer = died.get_node("Timer")

func _ready():
	get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED
	splash.show()
	hud.hide()
	main_menu.hide()
	died.hide()
	died.visible = false
#	splash_music.play(10)
	splash_timer.start(0.5)
	GameEngine.modulate(false)
	fighter = load("res://DandD/Classes/fighter.tscn").instantiate()
	var _err = GameEngine.connect("player_created",Callable(self,"on_player_created"))
	_err = died_timer.connect("timeout", Callable(self, "on_player_died_timeout"))
	if debugging_startup:
		call_deferred("debugging_ready")

func debugging_ready():
	var milestones = [
		"found-eastern-garrison",
		"explored-garrison",
		"sent-into-the-tunnels"
	]
	var inventory = [
		"res://DandD/Armor/helmet_plus_1.tscn",
		"res://DandD/Weapons/long_sword_plus_1.tscn",
		"res://DandD/Armor/chainmail_plus_1.tscn",
		"res://DandD/Potions/potion_of_healing.tscn",
		"res://Garrison/garrison_kitchen_key.tscn"
	]
	splash_timer.stop()
	hide_menu()
	GameEngine.clear_game()
	enter_game()
	GameEngine.time_in_minutes = 8*60
	var items = GameEngine.player.create_character(fighter)
	if false:
		GameEngine.abilities = [20, 20, 20]
	GameEngine.player.add_xp(2200)
	for m in milestones: GameEngine.complete_milestone(m)
	for i in inventory: GameEngine.player.add_to_inventory(load(i).instantiate(), false, true)
	for i in items: GameEngine.player.add_to_inventory(i, false, true)
	GameEngine.player.on_player_stats_changed()
	GameEngine.player.on_inventory_changed()
	#GameEngine.enter_scene("res://Town/town.tscn", "DebugPoint")
	#GameEngine.enter_scene("res://Wilderness/wilderness.tscn", "DebugPoint")
	#GameEngine.enter_scene("res://Garrison/garrison.tscn", "DebugPoint")
	GameEngine.enter_scene("res://GoblinCaves/goblin_caves.tscn", "DebugPoint")

func show_menu():
	main_menu.show()
#	splash_music.play(10)
	splash.show()
	GameEngine.pause()

func hide_menu():
	main_menu.hide()
	died.hide()
	splash_music.stop()
	splash.hide()
	GameEngine.resume()

func enter_game():
	hud.show()
	save.disabled = false
	game_in_progress = true
	died.visible = false
	GameEngine.modulate(true)

func on_player_created():
	var _err = GameEngine.player.connect("player_died",Callable(self,"on_player_died"))

func _unhandled_input(event:InputEvent):
	if event.is_action_pressed("menu") and game_in_progress:
		if main_menu.visible: hide_menu()
		elif not GameEngine.is_paused(): show_menu()
		else: return
	elif not game_in_progress and event.is_action_pressed("new-game"):
		_on_NewGame_pressed()
	else: return
	get_viewport().set_input_as_handled()

func _on_Splash_Timer_timeout():
	splash_timer.stop()
	save.disabled = true
	main_menu.show()

func _on_NewGame_pressed():
	hide_menu()
	GameEngine.clear_game()
	enter_game()
	var items = GameEngine.player.create_character(fighter)
	GameEngine.enter_scene(GameEngine.config.entry_scene, GameEngine.config.entry_point)
	await get_tree().process_frame
	var item_pos_node = GameEngine.get_scene_node("Home/StartingInventoryPosition")
	var item_pos = item_pos_node.global_position if item_pos_node else Vector2.ZERO
	for i in items:
		i.global_position = item_pos
		GameEngine.current_scene.add_child(i)
		item_pos.x += 32

func _on_Load_pressed():
	hide_menu()
	if not GameEngine.load_saved_game("res://savegame.tres"):
		# This isn't currently shown, need a popup
		GameEngine.message("Failed to load saved game")
	enter_game()
	
func _on_Save_pressed():
	if not GameEngine.save_game("res://savegame.tres"):
		# This isn't currently shown, need a popup
		GameEngine.message("Failed to save game")
	hide_menu()

func on_player_died():
	save.disabled = true
	game_in_progress = false
	died.set_deferred("visible", true)
	died_timer.start()

func on_player_died_timeout():
	show_menu()
	GameEngine.modulate(false)
