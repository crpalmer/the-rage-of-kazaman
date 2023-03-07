extends CanvasLayer

func _ready():
	GameEngine.connect("player_created", Callable(self, "player_created"))
	$ColorRect/Strength.connect("pressed", Callable(self, "strength_pressed"))
	$ColorRect/Dexterity.connect("pressed", Callable(self, "dexterity_pressed"))
	$ColorRect/Constitution.connect("pressed", Callable(self, "constitution_pressed"))

func player_created():
	GameEngine.player.connect("ability_improvement_needed", Callable(self, "start_selection"))

func start_selection():
	GameEngine.pause()
	set_deferred("visible", true)

func selected_ability(ability:Player.Ability):
	GameEngine.player.ability_improvement_selected(ability)
	set_deferred("visible", false)
	GameEngine.resume()

func strength_pressed():
	selected_ability(Player.Ability.STRENGTH)

func dexterity_pressed():
	selected_ability(Player.Ability.DEXTERITY)

func constitution_pressed():
	selected_ability(Player.Ability.CONSTITUTION)
