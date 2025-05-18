extends PanelContainer

@onready var name_label = $VBoxContainer/CharacterNameLabel
@onready var actions_label = $VBoxContainer/ActionsLeftLabel
@onready var attack_button = $VBoxContainer/Attack
@onready var move_button = $VBoxContainer/Move
@onready var power_attack_button = $VBoxContainer/PowerAttack
@onready var end_turn_button = $VBoxContainer/EndTurn

var tile_map

var current_character = null

func move_to_tile(target_tile: Vector2i):
	if current_character:
		current_character.move_to_tile(target_tile)

func update_ui(character):
	current_character = character
	current_character.clear_highlights()
	name_label.text = "Turn: " + character.data.characterName
	actions_label.text = "Actions Left: " + str(ActionTrackerInstance.actions_left)

func _ready():
	attack_button.pressed.connect(_on_attack_pressed)
	power_attack_button.pressed.connect(_on_power_attack_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	move_button.pressed.connect(_on_move_pressed)
	tile_map = get_node("/root/Main/TileMapLayer")  # or actual path in your scene

func _on_attack_pressed():
	if current_character:
		var target_ac = 10
		current_character.make_attack(target_ac)
		update_ui(current_character)

func _on_move_pressed():
	if current_character:
		current_character.clear_highlights()
		current_character.show_reachable_tiles()
		
		

func _on_power_attack_pressed():
	if current_character:
		current_character.use_feat("Power Attack")
		update_ui(current_character)

func _on_end_turn_pressed():
	if current_character:
		CombatManagerInstance.end_turn()
