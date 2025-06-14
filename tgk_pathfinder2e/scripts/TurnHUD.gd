extends PanelContainer

@onready var name_label = $VBoxContainer/CharacterNameLabel
@onready var actions_label = $VBoxContainer/ActionsLeftLabel
#@onready var attack_button = $VBoxContainer/Attack
#@onready var move_button = $VBoxContainer/Move
#@onready var power_attack_button = $VBoxContainer/PowerAttack
#@onready var end_turn_button = $VBoxContainer/EndTurn
@onready var actions = $VBoxContainer/Actions
var move_popup

var tile_map

var current_character = null

@onready var camera = get_node("/root/Main/Camera2D")

var baseActions: Array = ["Move", "Move2", "Move3"]

func _process(delta):
	if camera:
		var center = camera.get_screen_center_position()
		var offset = Vector2(800, 0)  # adjust distance to the right
		global_position = center + offset - size * Vector2(1, 0.5)

func move_to_tile(target_tile: Vector2i):
	if current_character:
		current_character.move_to_tile(target_tile)

func make_atack(target_coords: Vector2i):
	var target = tile_map.get_enemy(target_coords, current_character.data.is_player_character)
	print("Make atack against: ", target)
	#var target_ac = target.data.armorClass
	
	#update_ui(current_character)
	current_character.make_attack(target)
	update_ui(current_character)
	

#func queue_free_children():
	#for child in get_children():
		#child.queue_free()

func update_ui(character):
	#action_buttons.queue_free_children()
	for child in actions.get_children():
		child.queue_free()
	
	current_character = character
	current_character.clear_highlights()
	
	name_label.text = "Turn: " + character.data.characterName
	actions_label.text = "Actions Left: " + str(ActionTrackerInstance.actions_left)
	
	
	print("Aditional Actions: ", character.data.additionalActions)
	for action in baseActions + character.data.additionalActions:
		var button = Button.new()
		button.text = action
		button.pressed.connect(func():
			current_character.use_action(action)
			#update_ui(character)
		)
		#if action == "Move":
			#var popup: PopupMenu = PopupMenu.new()
			#popup.clear()
			#popup. add_item("Move (1 Action)", 1)
			#popup.add_item("Move (2 Actions)", 2)
			#popup.add_item("Move (3 Actions)", 3)
			#popup.id_pressed.connect(_on_move_action_selected)
			#button.add_child(popup)
		actions.add_child(button)
	
	#print("Weapon equiped: ", character.data.weaponEquiped)
	for weapon in character.data.weaponEquiped:
		var button = Button.new()
		button.text = "Strike with %s" % weapon.weapon_name
		button.pressed.connect(func():
			current_character.use_action("Strike", {"weapon":weapon})
		)
		actions.add_child(button)

	var button = Button.new()
	button.text = "End turn"
	#button.text = "Strike with %s" % weapon.weapon_name
	button.pressed.connect(func():
		current_character.use_action("End turn")
	)
	actions.add_child(button)
	

func _ready():
	#attack_button.pressed.connect(_on_attack_pressed)
	#power_attack_button.pressed.connect(_on_power_attack_pressed)
	#end_turn_button.pressed.connect(_on_end_turn_pressed)
	#move_button.pressed.connect(_on_move_pressed)
	tile_map = get_node("/root/Main/TileMapLayer")  # or actual path in your scene

func _on_attack_pressed():
	if current_character:
		current_character.clear_highlights()
		current_character.show_reachable_enemies()
		
func _on_move_action_selected(id):
	_on_move_pressed(id)
	
func _on_move_pressed(actions: int):
	if current_character:
		current_character.clear_highlights()
		current_character.show_reachable_tiles(actions)
		


func _on_power_attack_pressed():
	if current_character:
		current_character.use_feat("Power Attack")
		update_ui(current_character)

func _on_end_turn_pressed():
	if current_character:
		CombatManagerInstance.end_turn()
