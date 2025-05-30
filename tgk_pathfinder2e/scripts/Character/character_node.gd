extends Node2D
#class_name Character

#@onready var tile_map: TileMap = $"../../TileMap"
@onready var tile_map: TileMapLayer = $"../../TileMapLayer"
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var main: Node2D = $"../.."

@onready var data: CharacterData = $CharacterData

@onready var log = get_node("/root/Main/LogPanel")


var highlight_color = "#ffffff"
var is_modulated: = false
var enemies_characters: Array

func demodulate():
	sprite_2d.modulate = "#ffffff"

#func take_damage(dmg: int):
	#print("%s takes %d damage ", data.characterName, dmg)
	#data.currentHP -= dmg

func make_attack(target):
	var target_ac = target.data.armorClass
	var str_mod = RuleEngine.get_modifier(data.attributes["STR"])
	var result = RuleEngine.resolve_attack(str_mod + data.level, target_ac)
	if ActionTrackerInstance.use_action(1):
		print("Attack result:", result)
		log.add_log_entry("%s attacks %s, Atack roll: %d, Total: %d, Result: %s" % [data.characterName, target.data.characterName, result["roll"], result["total"], result["result"]])
		if result["result"] == "hit" or result["result"] == "critical_hit":
			target.take_damage(RuleEngine.calculate_damage("1d6", -1, "physical")["amount"])
		
			
		
		
func clear_highlights():
	for cell in tile_map.modulated_cells:
		tile_map.modulated_cells[cell] = Color(1, 1, 1, 1) 
	tile_map.notify_runtime_tile_data_update()
	tile_map.update_internals()
	tile_map.modulated_cells.clear()
	#tile_map.modulated_cells[Vector2i(0,0)] = Color(1.0, 1.0, 1.0, 1) 
	print("Clear")
	

func show_reachable_tiles():
	var origin = tile_map.local_to_map(global_position)
	var reachable = get_reachable_tiles(origin, data.speed)
	
	#clear_highlights()
	for cell in reachable:
		tile_map.modulated_cells[cell] = Color(0.0, 1.0, 1.0, 0.4) 
	#print("Before Update")
	tile_map.set_selection_phase(tile_map.SelectionPhase.MOVE)
	tile_map.notify_runtime_tile_data_update()
	print("After Update")

func get_reachable_tiles(origin: Vector2i, max_range: int) -> Array:
	var visited = {}
	var frontier = [origin]
	visited[origin] = 0
	while frontier:
		var current = frontier.pop_front()
		var distance = visited[current]
		for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var neighbor = current + dir
			if is_tile_walkable(current, neighbor) and not visited.has(neighbor):
				var new_distance = distance + 1
				if new_distance <= max_range:
					visited[neighbor] = new_distance
					frontier.append(neighbor)
	visited.erase(origin)
	return visited.keys()

func is_tile_walkable(origin_tile_pos: Vector2i, target_tile_pos: Vector2i) -> bool:
	var target_data = tile_map.get_cell_tile_data(target_tile_pos)
	var current_data = tile_map.get_cell_tile_data(origin_tile_pos)
	
	return target_data != null and target_data.get_custom_data("walkable") and (abs(target_data.get_custom_data("height") - current_data.get_custom_data("height")) <= 5 )

func clear_enemies_highlights():
	for enemy in enemies_characters:
		enemy.demodulate()
		tile_map.modulated_cells[enemy.get_tile_coords()] = Color(1,1,1,1)
	enemies_characters.clear()
	tile_map.notify_runtime_tile_data_update()
	tile_map.modulated_cells.clear()
	#tile_map.notify_runtime_tile_data_update()
	#tile_map.update_internals()
	#tile_map.modulated_cells.clear()
	#tile_map.modulated_cells[Vector2i(0,0)] = Color(1.0, 1.0, 1.0, 1) 
	print("Enemies Clear")

func show_reachable_enemies():
	var origin = tile_map.local_to_map(global_position)
	#var enemies_result = get_reachable_enemies(origin, data.reach)
	#var enemies_cells = enemies_result[0]
	#var enemies_characters = enemies_result[1]
	enemies_characters = get_reachable_enemies(origin, data.reach)
	
	#clear_highlights()
	print(enemies_characters)
	for enemy in enemies_characters:
		enemy.sprite_2d.modulate = Color(1.0, 0.0, 0.0, 0.4)
		#enemy.
		print("Enemy coords: ", enemy.get_tile_coords())
		tile_map.modulated_cells[enemy.get_tile_coords()] = Color(1.0, 0.0, 0.0, 0.4)
		
	tile_map.set_selection_phase(tile_map.SelectionPhase.ATACK)
	#for enemy in enemies_characters:
		#enemy.sprite_2d.modulate = Color(1.0, 0.0, 0.0, 0.4)
		
	
	#print("Before Update")
	tile_map.notify_runtime_tile_data_update()

func get_reachable_enemies(origin: Vector2i, max_range: int) -> Array:
	var visited = {}
	var is_root = true
	var frontier = [origin]
	var enemies_characters = []
	visited[origin] = 0
	while frontier:
		var current = frontier.pop_front()
		var distance = visited[current]
		for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var neighbor = current + dir
			if  is_tile_walkable(current, neighbor) and not visited.has(neighbor):
				var new_distance = distance + 1
				if new_distance <= max_range:
					visited[neighbor] = new_distance
					
					if tile_map.has_enemy(neighbor, data.is_player_character):
						enemies_characters.append(tile_map.get_enemy(neighbor, data.is_player_character))
					frontier.append(neighbor)
	#visited.erase(origin)
	return  enemies_characters


func start_turn():
	ActionTrackerInstance.reset_turn()
	print("%s starts turn!" % data.characterName)

func end_turn():
	print("%s ends turn." % data.characterName)

func get_initiative():
	return data.perception + RuleEngine.roll_d20()
	
func apply_frightened():
	RuleEngine.apply_condition(self, "Frightened", 2)
	
func use_feat(name: String):
	var feat = data.feats.get(name)
	if feat and feat["type"] == "action":
		if ActionTrackerInstance.use_action(feat["cost"]):
			match name:
				"Power Attack":
					# Double damage example
					var base_dmg = RuleEngine.calculate_damage("1d8", RuleEngine.get_modifier(data.attributes["STR"]))
					base_dmg["amount"] *= 2
					#apply_damage(base_dmg)

func take_damage(dmg: int):
	log.add_log_entry("%s take %d damage" % [data.characterName, dmg])
	data.currentHP = max(data.currentHP - dmg, 0)
	print("Remaining HP:", data.currentHP)
	
func on_save_throw(save_type: String, dc: int, possible_results: String):
	var ref_mod = RuleEngine.get_modifier(data.attributes["DEX"])
	var save_result = RuleEngine.resolve_saving_throw(dc, ref_mod)

	match save_result["result"]:
		"critical_failure":
			take_damage(24)  # double damage
		"failure":
			take_damage(12)
		"success":
			take_damage(6)
		"critical_success":
			take_damage(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.modulate = "#ffffff"
	var cur_tile = tile_map.local_to_map(global_position)
	tile_map.get_obj()[cur_tile[0]][cur_tile[1]].append(self)
	#character = CharacterData
	#character.Stats.setSTR(12)
	#print(character.Stats.getSTR())
	

var is_moving = false
var is_selected = false

func _physics_process(delta: float) -> void:
	if not is_moving:
		return
		
	if global_position == sprite_2d.global_position:
		is_moving = false
		return
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 1)	

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if is_selected:
			main.set_character_selection(false)
		self.deselect()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_selected:
			var mouse_pos = get_global_mouse_position()
			var tile_mouse_pos = tile_map.local_to_map(mouse_pos)
			move_to_tile(tile_mouse_pos)

func select():
	#print(tile_map.get_obj())
	#print("Character select")
	if main.is_any_character_selected():
		return
	#ar shader_color = sprite_2d.material.get_shader_param("line_color")
	sprite_2d.modulate = "#a9c6ff"
	main.set_character_selection(true)
	is_selected = true
	
func deselect():
	sprite_2d.modulate = "#ffffff"
	is_selected = false

func get_tile_coords():
	return tile_map.local_to_map(global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_moving:
		return
	#if Input.is_action_pressed("left_click"):
		#print("Click")
	#if Input.is_action_pressed("up"):
		#move(Vector2.UP)
	#if Input.is_action_pressed("down"):
		#move(Vector2.DOWN)	
	
#func move(direction: Vector2):
	#var cur_tile = tile_map.local_to_map(global_position)
	##print(cur_tile)
	#
	#var target_tile = Vector2i(cur_tile.x + direction.x, cur_tile.y + direction.y)
	##print(target_tile)
	#is_moving = true
	#global_position = tile_map.map_to_local(target_tile)
	#sprite_2d.global_position = tile_map.map_to_local(cur_tile)

func move_to_tile(target_tile: Vector2i):

	var scene_size = tile_map.get_used_rect().size
	if target_tile[0] < 0 or target_tile[0] >= scene_size[0] or target_tile[1] < 0 or target_tile[1] >= scene_size[1]:
		return
	
	ActionTrackerInstance.use_action(1)
		
	clear_highlights()
	var cur_tile = tile_map.local_to_map(global_position)
	tile_map.get_obj()[cur_tile[0]][cur_tile[1]].erase(self)
	tile_map.get_obj()[target_tile[0]][target_tile[1]].append(self)
	
	is_moving = true
	global_position = tile_map.map_to_local(target_tile)
	sprite_2d.global_position = tile_map.map_to_local(cur_tile)
