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

func _ready():
	OS.set_window_maximized(true)
	splash.show()
	hud.hide()
	main_menu.hide()
#	splash_music.play(10)
	splash_timer.start(0.01)
	GameEngine.modulate(false)
	fighter = load("res://DandD/Classes/Fighter.tscn").instance()
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
	#GameEngine.enter_scene("res://Garrison/GarrisonLevel1.tscn", "DebugPoint")
	GameEngine.enter_scene("res://Town/Town.tscn", "DebugPoint")

func show_menu():
	main_menu.show()
#	splash_music.play(10)
	splash.show()

func hide_menu():
	main_menu.hide()
	splash_music.stop()
	splash.hide()

func enter_game():
	connect_player_death()
	hud.show()
	save.disabled = false
	GameEngine.modulate(true)

func connect_player_death():
	var _err = GameEngine.player.connect("player_died", self, "on_player_died")
	game_in_progress = true

func _process(_delta):
	if Input.is_action_just_released("menu") and game_in_progress and not GameEngine.is_paused():
		if main_menu.visible: hide_menu()
		else: show_menu()

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
	show_menu()
	game_in_progress = false
	GameEngine.modulate(false)
