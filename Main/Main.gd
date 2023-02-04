extends Node2D

var game_in_progress = false
var fighter

func _ready():
	OS.set_window_maximized(true)
	$Splash.show()
	$HUD.hide()
	$MainMenu.hide()
	$InformationalText.hide()
#	$Splash/Music.play(10)
	$Splash/Timer.start(0.01)
	GameEngine.modulate(false)
	fighter = load("res://DandD/Classes/Fighter.tscn").instance()


func show_menu():
	$MainMenu.show()
#	$Splash/Music.play(10)
	$Splash.show()

func hide_menu():
	$MainMenu.hide()
	$Splash/Music.stop()
	$Splash.hide()

func enter_game():
	connect_player_death()
	$HUD.show()
	GameEngine.modulate(true)

func connect_player_death():
	var _err = GameEngine.player.connect("player_died", self, "on_player_died")
	game_in_progress = true

func _process(_delta):
	if Input.is_action_just_released("menu") and game_in_progress and not GameEngine.is_paused():
		if $MainMenu.visible: hide_menu()
		else: show_menu()

func _on_Splash_Timer_timeout():
	$Splash/Timer.stop()
	$MainMenu/Save.disabled = true
	$MainMenu.show()

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
#	$InformationalText.message("You awake in a fright.\n\nYou hear a commotion outside your house.  What could be happening in the middle of the night??\n\nMaybe it would be wise to go investigate.")

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
	$MainMenu/Save.disabled = true
	show_menu()
	game_in_progress = false
	GameEngine.modulate(false)
