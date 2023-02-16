extends Node2D

var game_in_progress = false
var fighter

export var debugging_startup = true
onready var splash = $Splash
onready var splash_timer = $Splash/Timer
onready var splash_music = $Splash/Music
onready var hud = $HUD
onready var main_menu = $MainMenu
onready var save = $MainMenu/Save
onready var died = $MainMenu/Died

func _ready():
	OS.set_window_maximized(true)
	splash.show()
	hud.hide()
	main_menu.hide()
	died.visible = false
#	splash_music.play(10)
	splash_timer.start(0.5)
	GameEngine.modulate(false)
	fighter = load("res://DandD/Classes/Fighter.tscn").instance()
	var _err = GameEngine.connect("player_created", self, "on_player_created")
	if debugging_startup:
		call_deferred("debugging_ready")

func debugging_ready():
	splash_timer.stop()
	hide_menu()
	GameEngine.new_game()
	enter_game()
	var items = GameEngine.player.create_character(fighter)
	GameEngine.complete_milestone("found-eastern-garrison")
	GameEngine.player.add_xp(500)
	GameEngine.player.add_to_inventory(load("res://DandD/Armor/HelmetPlus1.tscn").instance(), true)
	GameEngine.player.add_to_inventory(load("res://DandD/Weapons/LongSwordPlus1.tscn").instance(), true)
	for item in items: GameEngine.player.add_to_inventory(item, true)
	#GameEngine.enter_scene("res://Town/Town.tscn", "DebugPoint")
	GameEngine.enter_scene("res://Wilderness/Wilderness.tscn", "DebugPoint")
	#GameEngine.enter_scene("res://Garrison/GarrisonLevel1.tscn", "DebugPoint")

func show_menu():
	main_menu.show()
#	splash_music.play(10)
	splash.show()
	GameEngine.pause()

func hide_menu():
	main_menu.hide()
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
	var _err = GameEngine.player.connect("player_died", self, "on_player_died")

func _input(event:InputEvent):
	if event.is_action_pressed("menu") and game_in_progress:
		if main_menu.visible: hide_menu()
		elif not GameEngine.is_paused(): show_menu()
	elif not game_in_progress and event.is_action_pressed("new-game"):
		_on_NewGame_pressed()

func _on_Splash_Timer_timeout():
	splash_timer.stop()
	save.disabled = true
	main_menu.show()

func _on_NewGame_pressed():
	hide_menu()
	GameEngine.new_game()
	enter_game()
	var items = GameEngine.player.create_character(fighter)
	GameEngine.enter_scene(GameEngine.config.entry_scene, GameEngine.config.entry_point)
	yield(get_tree(), "idle_frame")
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
	call_deferred("show_menu")
	GameEngine.modulate(false)
