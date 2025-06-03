# CombatManager.gd
extends Node
#class_name CombatManager

var turn_order: Array = []
var current_turn_index: int = 0

#@onready var TurnHUD = get_node("TurnHUD")
@onready var turn_hud = get_tree().get_root().get_node("Main/TurnHUD")
@onready var tile_map: TileMapLayer = $TileMapLayer

func start_combat(characters: Array):
	turn_order = roll_initiative(characters)
	#print(turn_order)
	current_turn_index = 0
	start_turn()
	
func start_turn():
	var char = turn_order[current_turn_index]
	char.start_turn()
	if not char.data.is_player_character:
		char.make_automatic_turn()
		return
	
	if turn_hud:
		print(char.data.characterName)
		turn_hud.update_ui(char)
	else:
		print("TurnHUD not found!")

func end_turn():
	#turn_order[current_turn_index].end_turn()
	current_turn_index = (current_turn_index + 1) % turn_order.size()
	start_turn()

func roll_initiative(characters: Array) -> Array:
	var rolls = []
	for c in characters:
		var roll = c.get_initiative()
		rolls.append({"char": c, "init": roll})
	rolls.sort_custom(func(a, b): return b["init"] - a["init"])
	return rolls.map(func(x): return x["char"])
