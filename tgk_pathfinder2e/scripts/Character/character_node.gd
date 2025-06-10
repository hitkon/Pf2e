extends Node2D
class_name Character

#@onready var tile_map: TileMap = $"../../TileMap"
@onready var tile_map: TileMapLayer = $"../../TileMapLayer"
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var main: Node2D = $"../.."

@onready var data: CharacterData = $CharacterData

@onready var log = get_node("/root/Main/LogPanel")

signal animtion_end

var highlight_color = "#ffffff"
var is_modulated: = false
var enemies_characters: Array
var atack_number: int = 0
var active_action: String =  ""
#var move_target_position: Vector2i

var is_moving = false
var is_selected = false
var move_speed := 200
#var move_queue: Array = []
#var ancestor_dict: Dictionary = {}
var ancestor_dict: Dictionary= {}
var calculated_distances: Dictionary = {}
var path_queue: Array = []
var actions_reserved
var attack_weapon: WeaponResource

func demodulate():
	sprite_2d.modulate = "#ffffff"

func addActionType(actionName: String):
	data.additionalActions.append(actionName)

func use_action(action_name: String, params:Dictionary = {}):
	
	match action_name:
		"Strike":
			if ActionTracker.get_actions_left() < 1:
				log.add_log_entry("Not enough actions to melee atack")
				print("Not enough actions")
				return
			attack_weapon = params["weapon"]
			clear_highlights()
			show_reachable_enemies(params["weapon"])
		"Move":
			if ActionTracker.get_actions_left() < 1:
				log.add_log_entry("Not enough actions to move")
				print("Not enough actions")
				return
			clear_highlights()
			actions_reserved = 1
			show_reachable_tiles(1)
		"Move2":
			if ActionTracker.get_actions_left() < 2:
				log.add_log_entry("Not enough actions to move")
				print("Not enough actions")
				return
			clear_highlights()
			actions_reserved = 2
			show_reachable_tiles(2)
		"Move3":
			if ActionTracker.get_actions_left() < 3:
				log.add_log_entry("Not enough actions to move")
				print("Not enough actions")
				return
			clear_highlights()
			actions_reserved = 3
			show_reachable_tiles(3)
		"End turn":
			log.add_log_entry("%s ends turn" % [data.characterName])
			CombatManagerInstance.end_turn()
		"Vicious Swing":
			if ActionTracker.get_actions_left() < 2:
				log.add_log_entry("Not enough actions to Vicious Swing")
				print("Not enough actions")
				return
			clear_highlights()
			active_action = action_name
			show_reachable_enemies(params["weapon"])
		"Sudden Charge":			
			pass
			return
			

func make_vicious_swing(target, result):
	ActionTrackerInstance.use_action(2)
	print("Vicious swing:", result)
	log.add_log_entry("%s attacks with vicious swing %s, Atack roll: %d, Total: %d, Result: %s" % [data.characterName, target.data.characterName, result["roll"], result["total"], result["result"]])
	if result["result"] == "hit" or result["result"] == "critical_hit":
		target.take_damage(2 * RuleEngine.calculate_damage(attack_weapon.damage, data.attributes["STR"], "physical")["amount"])
	atack_number += 2
		
func make_simple_strike(target, result):
	ActionTrackerInstance.use_action(1)
	print("Attack result:", result)
	log.add_log_entry("%s attacks %s, Atack roll: %d, Total: %d, Result: %s" % [data.characterName, target.data.characterName, result["roll"], result["total"], result["result"]])
	if result["result"] == "hit" or result["result"] == "critical_hit":
		target.take_damage(RuleEngine.calculate_damage(attack_weapon.damage, data.attributes["STR"], "physical")["amount"])
	atack_number += 1

func make_attack(target):
	clear_enemies_highlights()
	
	var target_ac = target.data.armorClass
	var str_mod = RuleEngine.get_modifier(data.attributes["STR"])
	var result = RuleEngine.resolve_attack(str_mod + data.level + data.weaponProficiency[attack_weapon.proficiency], target_ac)
	
	if active_action == "":
		make_simple_strike(target,result)
	if active_action == "Vicious Swing":
		make_vicious_swing(target, result)
		
func clear_highlights():
	print("Clear cell highlight: ", tile_map.modulated_cells)
	for cell in tile_map.modulated_cells:
		print("Clear cell highlight")
		tile_map.modulated_cells[cell] = Color(1, 1, 1, 1) 
	tile_map.notify_runtime_tile_data_update()
	tile_map.update_internals()
	tile_map.modulated_cells.clear()
	#tile_map.modulated_cells[Vector2i(0,0)] = Color(1.0, 1.0, 1.0, 1) 
	print("Clear")
	

func show_reachable_tiles(actions: int = 1):
	var origin = tile_map.local_to_map(global_position)
	var reachable = get_reachable_tiles(origin, data.speed * (actions-1), data.speed * actions)
	
	for cell in reachable:
		tile_map.modulated_cells[cell] = Color(0.0, 1.0, 1.0, 0.4) 
	
	tile_map.set_selection_phase(tile_map.SelectionPhase.MOVE)
	tile_map.notify_runtime_tile_data_update()
	print("After Update")

func get_reachable_tiles(origin: Vector2i, min_range: int, max_range) -> Array:
	var result = []
	var visited = {}
	var frontier = {origin: [0,false]}
	calculated_distances.clear()
	ancestor_dict.clear()
	ancestor_dict[origin] = origin
	while not frontier.is_empty():
		var current 
		var distance = [10**9, false]
		for tile in frontier.keys():
			if is_less_distances( frontier[tile], distance):
				current = tile
				distance = frontier[tile]
		frontier.erase(current)

		visited[current] = true
		calculated_distances[current] = distance
		if distance[0] > min_range and distance[0] <= max_range and not tile_map.has_character(current):
			result.append(current)
		
		for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(-1,1), Vector2i(1,-1), Vector2i(-1,-1)]:
			var neighbor = current + dir
			if  is_tile_walkable(current, neighbor) and not visited.has(neighbor):
				
				var new_distance
				if abs(dir[0]) + abs(dir[1]) == 2:
					if distance[1]:
						new_distance = [distance[0] + 2, false]	
					else:
						new_distance = [distance[0] + 1, true]
				else:
					new_distance = [distance[0] + 1, distance[1]]
				
				if tile_map.has_enemy(neighbor, data.is_player_character):
					new_distance[0] += 1
				if tile_map.get_cell_tile_data(neighbor).get_custom_data("difficultTerrain"):
					new_distance[0] += 1
				
				if (new_distance[0] <= max_range) and ( not frontier.has(neighbor) or is_less_distances(new_distance, frontier[neighbor])):
					frontier[neighbor] = new_distance
					ancestor_dict[neighbor] = current
	return result

func is_tile_walkable(origin_tile_pos: Vector2i, target_tile_pos: Vector2i) -> bool:
	var scene_size = tile_map.get_used_rect().size
	if target_tile_pos[0] < 0 or target_tile_pos[0] >= scene_size[0] or target_tile_pos[1] < 0 or target_tile_pos[1] >= scene_size[1]:
		return false
	var target_data = tile_map.get_cell_tile_data(target_tile_pos)
	var current_data = tile_map.get_cell_tile_data(origin_tile_pos)
	#print("from ", origin_tile_pos , "to ", target_tile_pos ," has character ", tile_map.has_character(target_tile_pos))
	return target_data != null and target_data.get_custom_data("walkable") and (abs(target_data.get_custom_data("height") - current_data.get_custom_data("height")) <= 5) #and not tile_map.has_character(target_tile_pos)

func clear_enemies_highlights():
	for enemy in enemies_characters:
		enemy.deselect()
		print("Enemy modulate: ", enemy.modulate)
		tile_map.modulated_cells[enemy.get_tile_coords()] = Color(1,1,1,1)
	enemies_characters.clear()
	tile_map.notify_runtime_tile_data_update()
	tile_map.update_internals()
	tile_map.modulated_cells.clear()
	#tile_map.notify_runtime_tile_data_update()
	#tile_map.update_internals()
	#tile_map.modulated_cells.clear()
	#tile_map.modulated_cells[Vector2i(0,0)] = Color(1.0, 1.0, 1.0, 1) 
	print("Enemies Clear")

func show_reachable_enemies(weapon: WeaponResource):
	var origin = tile_map.local_to_map(global_position)
	#var enemies_result = get_reachable_enemies(origin, data.reach)
	#var enemies_cells = enemies_result[0]
	#var enemies_characters = enemies_result[1]
	enemies_characters = get_reachable_enemies(origin, weapon.range)
	
	#clear_highlights()
	print(enemies_characters)
	for enemy in enemies_characters:
		enemy.sprite_2d.modulate = Color(1.0, 0.0, 0.0, 0.4)
		#enemy.
		print("Enemy coords: ", enemy.get_tile_coords())
		tile_map.modulated_cells[enemy.get_tile_coords()] = Color(1.0, 0.0, 0.0, 0.4)
		
	tile_map.set_selection_phase(tile_map.SelectionPhase.ATACK)

	tile_map.notify_runtime_tile_data_update()

func get_reachable_enemies(origin: Vector2i, max_range: int) -> Array:
	var result = []
	var visited = {}
	var frontier = {origin: [0,false]}
	var min_range = 0
	calculated_distances.clear()
	ancestor_dict.clear()
	ancestor_dict[origin] = origin
	while not frontier.is_empty():
		var current 
		var distance = [10**9, false]
		for tile in frontier.keys():
			if is_less_distances( frontier[tile], distance):
				current = tile
				distance = frontier[tile]
		frontier.erase(current)

		visited[current] = true
		calculated_distances[current] = distance
		print("Enemies: ", distance, current, tile_map.has_enemy(current, data.is_player_character), max_range)
		if distance[0] <= max_range and tile_map.has_enemy(current, data.is_player_character):
			result.append(tile_map.get_enemy(current, data.is_player_character))
		if distance[0] == max_range:
			continue
		
		for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(-1,1), Vector2i(1,-1), Vector2i(-1,-1)]:
			var neighbor = current + dir
			if  is_tile_walkable(current, neighbor) and not visited.has(neighbor):
				
				var new_distance
				if abs(dir[0]) + abs(dir[1]) == 2:
					if distance[1]:
						new_distance = [distance[0] + 2, false]	
					else:
						new_distance = [distance[0] + 1, true]
				else:
					new_distance = [distance[0] + 1, distance[1]]
				
				#if tile_map.has_enemy(neighbor, data.is_player_character):
					#new_distance[0] += 1
				#if tile_map.get_cell_tile_data(neighbor).get_custom_data("difficultTerrain"):
					#new_distance[0] += 1
				
				if new_distance[0] <= max_range and (not frontier.has(neighbor) or is_less_distances(new_distance, frontier[neighbor])):
					frontier[neighbor] = new_distance
					ancestor_dict[neighbor] = current
	return result


func start_turn():
	ActionTrackerInstance.reset_turn()
	print("%s starts turn!" % data.characterName)

func end_turn():
	print("%s ends turn." % data.characterName)
	CombatManagerInstance.end_turn()

func get_initiative():
	return data.perception + RuleEngine.roll_d20()
	
func apply_frightened():
	RuleEngine.apply_condition(self, "Frightened", 2)

func take_damage(dmg: int):
	log.add_log_entry("%s take %d damage" % [data.characterName, dmg])
	data.currentHP = max(data.currentHP - dmg, 0)
	if data.currentHP == 0:
		log.add_log_entry("%s is dead" % data.characterName)
		CombatManagerInstance.remove_character_from_queue(self)
		var cur_tile = tile_map.local_to_map(global_position)
		tile_map.get_obj()[cur_tile[0]][cur_tile[1]].erase(self)
		sprite_2d.visible = false
	else:
		if data.currentHP <= data.maxHP / 4:
			log.add_log_entry("%s is heavy wounded" % data.characterName)
		elif data.currentHP <= data.maxHP / 2:
			log.add_log_entry("%s is wounded" % data.characterName)	
		else:
			log.add_log_entry("%s looks healthy" % data.characterName)	
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
	#connect("my_signal", self, "my_method")
	sprite_2d.modulate = "#ffffff"
	var cur_tile = tile_map.local_to_map(global_position)
	tile_map.get_obj()[cur_tile[0]][cur_tile[1]].append(self)

func _physics_process(delta: float) -> void:
	if not is_moving:
		return
	#print(global_position, sprite_2d.global_position)	
	#print(delta)
	if global_position == sprite_2d.global_position:
		if path_queue.is_empty():
			is_moving = false
			animtion_end.emit()
			return
		global_position = tile_map.map_to_local(path_queue.front())
		sprite_2d.global_position = tile_map.map_to_local(ancestor_dict[path_queue.front()])
		path_queue.pop_front()
		return
		#return
	
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, delta*move_speed)	
	#sprite_2d.global_position = tile_map.map_to_local(path_queue.front())

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


func _process(delta: float) -> void:
	if is_moving:
		#global_position = global_position.move_toward(move_target_position, move_speed * delta)
		return

func build_path_queue(target_tile: Vector2i):
	
	var path: Array = []
	var cur_path_tile = target_tile
	
	while ancestor_dict[cur_path_tile] != cur_path_tile:
		path.append(cur_path_tile)
		cur_path_tile = ancestor_dict[cur_path_tile]	
	
	path.reverse()
	#print("path", path)
	return path
	
	
func is_less_distances(dist1: Array, dist2: Array):
	if dist1[0] < dist2[0] or (dist1[0] == dist2[0] and dist1[1] == false and dist2[1] == true):
		return true
	return false
	

func seek_nearest_enemy(origin: Vector2i) -> Dictionary:
	var result = {}
	var visited = {}
	var frontier = {origin: [0,false]}
	calculated_distances.clear()
	ancestor_dict.clear()
	ancestor_dict[origin] = origin
	while not frontier.is_empty():
		var current 
		var distance = [10**9, false]
		for tile in frontier.keys():
			if is_less_distances( frontier[tile], distance):
				current = tile
				distance = frontier[tile]
		frontier.erase(current)

		visited[current] = true
		calculated_distances[current] = distance
		
		for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1), Vector2i(1,1), Vector2i(-1,1), Vector2i(1,-1), Vector2i(-1,-1)]:
			var neighbor = current + dir
			if  is_tile_walkable(current, neighbor) and not visited.has(neighbor):
				
				var new_distance
				if abs(dir[0]) + abs(dir[1]) == 2:
					if distance[1]:
						new_distance = [distance[0] + 2, false]	
					else:
						new_distance = [distance[0] + 1, true]
				else:
					new_distance = [distance[0] + 1, distance[1]]
				
				if tile_map.has_enemy(neighbor, data.is_player_character):
					new_distance[0] += 1
				if tile_map.get_cell_tile_data(neighbor).get_custom_data("difficultTerrain"):
					new_distance[0] += 1
					
				if tile_map.has_enemy(neighbor, data.is_player_character) and not tile_map.has_character(current):
					result["enemy"] = tile_map.get_enemy(neighbor, data.is_player_character)
					result["target_tile"] = current
					result["distance"] = distance
					return result
				
				if not frontier.has(neighbor) or is_less_distances(new_distance, frontier[neighbor]):
					frontier[neighbor] = new_distance
					ancestor_dict[neighbor] = current
	return {}

func build_path_to_the_nearest_reachable_enemy(target_tile: Vector2i, max_distance: int):
	var cur = target_tile
	while calculated_distances[cur][0] > max_distance or tile_map.has_character(cur):
		cur = ancestor_dict[cur]
	
	return build_path_queue(cur)
	

func make_enemy_move(targets: Dictionary) -> void:
	var num_turns_for_move: int = int(ceil(targets["distance"][0] / float(data.speed)))
	print("Num of turns: ", num_turns_for_move)
	if num_turns_for_move > 3:
		path_queue = build_path_to_the_nearest_reachable_enemy(targets["target_tile"], 3*data.speed)
	else:
		path_queue = build_path_to_the_nearest_reachable_enemy(targets["target_tile"], num_turns_for_move*data.speed)
	ActionTrackerInstance.use_action(num_turns_for_move)
	for i in range(num_turns_for_move):
		log.add_log_entry("%s moves" % data.characterName)
	
	var cur_tile = tile_map.local_to_map(global_position)
	var target_tile = targets["target_tile"]
	tile_map.get_obj()[cur_tile[0]][cur_tile[1]].erase(self)
	tile_map.get_obj()[target_tile[0]][target_tile[1]].append(self)
	
	is_moving = true
	global_position = tile_map.map_to_local(path_queue.front())
	path_queue.pop_front()
	sprite_2d.global_position = tile_map.map_to_local(cur_tile)
	
func is_movement_end():
	return not is_moving
	

func make_automatic_turn():
	if data.character_behavior == data.Behavior.AGRESSIVE:
		# TODO get random weapon instead of 0
		var enemies = get_reachable_enemies(tile_map.local_to_map(global_position), data.weaponEquiped[0].range)
		if enemies.is_empty():
			var targets = seek_nearest_enemy(tile_map.local_to_map(global_position))
			#print("targets:", targets)
			if targets.is_empty():
				end_turn()
				return
			make_enemy_move(targets)
			await animtion_end
			attack_weapon = data.weaponEquiped[0]
			while ActionTrackerInstance.can_act():
				make_attack(targets["enemy"])
				ActionTrackerInstance.use_action(1)
			
		else:
			while ActionTrackerInstance.can_act():
				var enemy = enemies[randi() % enemies.size()]
				make_attack(enemy)
				ActionTrackerInstance.use_action(1)
				#var enemy = enemies[choice]
		
		end_turn()

func move_to_tile(target_tile: Vector2i):

	var scene_size = tile_map.get_used_rect().size
	if target_tile[0] < 0 or target_tile[0] >= scene_size[0] or target_tile[1] < 0 or target_tile[1] >= scene_size[1]:
		return
	
	ActionTrackerInstance.use_action(actions_reserved)
	for i in range(actions_reserved):
		log.add_log_entry("%s moves" % data.characterName)
	actions_reserved = 0
	clear_highlights()
	var cur_tile = tile_map.local_to_map(global_position)
	path_queue = build_path_queue(target_tile)	
	#path_queue = [target_tile]
	
	tile_map.get_obj()[cur_tile[0]][cur_tile[1]].erase(self)
	tile_map.get_obj()[target_tile[0]][target_tile[1]].append(self)
	
	is_moving = true
	global_position = tile_map.map_to_local(path_queue.front())
	path_queue.pop_front()
	sprite_2d.global_position = tile_map.map_to_local(cur_tile)
