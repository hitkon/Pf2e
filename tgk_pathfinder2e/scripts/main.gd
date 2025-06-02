extends Node2D
@onready var tile_map: TileMapLayer = $TileMapLayer
#@onready var combatManager: CombatManagerInstance

var playerCharacters: Array
var enemyCharacters: Array

var is_fight_mode: bool

@onready var amiri = $PlayerCharacters/Amiri
@onready var ezren = $PlayerCharacters/Ezren
@onready var kira = $PlayerCharacters/Kira
@onready var valeros = $PlayerCharacters/Valeros

var any_character_selected: bool = false
func is_any_character_selected():
	return any_character_selected
func set_character_selection(is_selected: bool):
	any_character_selected = is_selected

var scene_size
#scene_height = 30
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var tile_mouse_pos = tile_map.local_to_map(mouse_pos)
		print(tile_mouse_pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_fight_mode = true
	scene_size = tile_map.get_used_rect()
	print(scene_size.size)
	#print("Hellow world")
	valeros.addActionType("Powerful strike")
	
	playerCharacters.append($PlayerCharacters/Amiri)
	playerCharacters.append($PlayerCharacters/Valeros)
	playerCharacters.append($PlayerCharacters/Ezren)
	playerCharacters.append($PlayerCharacters/Kira)
	
	enemyCharacters.append($"EnemyCharacters/Big Rat1")
	enemyCharacters.append($"EnemyCharacters/Big Rat2")
	
	#print(playerCharacters + enemyCharacters)
	
	CombatManagerInstance.start_combat(playerCharacters + enemyCharacters)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
