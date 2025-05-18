extends PanelContainer

@onready var name_label = $VBoxContainer/CharacterNameLabel
@onready var actions_label = $VBoxContainer/ActionsLeftLabel
@onready var attack_button = $VBoxContainer/Attack
@onready var move_button = $VBoxContainer/Move
@onready var power_attack_button = $VBoxContainer/PowerAttack
@onready var end_turn_button = $VBoxContainer/EndTurn

var tile_map

var current_character = null

func update_ui(character):
	current_character = character
	name_label.text = "Turn: " + character.data.characterName
	actions_label.text = "Actions Left: " + str(ActionTrackerInstance.actions_left)

func _ready():
	attack_button.pressed.connect(_on_attack_pressed)
	power_attack_button.pressed.connect(_on_power_attack_pressed)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	move_button.pressed.connect(_on_move_pressed)
	tile_map = get_node("/root/Main/TileMap")  # or actual path in your scene

func _on_attack_pressed():
	if current_character:
		var target_ac = 10
		current_character.make_attack(target_ac)
		update_ui(current_character)

func _on_move_pressed():
	print(tile_map)
	if current_character:
		var origin = tile_map.local_to_map(current_character.global_position)
		print(origin==null)
		var reachable = current_character.get_reachable_tiles(origin, current_character.data.speed)
		current_character.highlight_tiles(reachable, Color(0, 0.6, 1, 0.6))
	#print("Move button pressed")
	#pass

func _on_power_attack_pressed():
	if current_character:
		current_character.use_feat("Power Attack")
		update_ui(current_character)

func _on_end_turn_pressed():
	if current_character:
		CombatManagerInstance.end_turn()
