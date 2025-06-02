extends TileMapLayer

var TurnHUD

var map_obj = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(TileMapLayer.has_method("queue_redraw"))
	TurnHUD = get_node("/root/Main/TurnHUD") 
	var sizes = get_used_rect().size
	print(sizes)
	for x in range(sizes[0]):
		map_obj.append([])
		for y in range(sizes[1]):
			map_obj[x].append([])
			map_obj[x][y] = []
	#map_obj = [[0 for y in range(sizes[0]) ] for x in range(sizes[0])]

	pass # Replace with function body.

func get_obj():
	return map_obj
	
func has_enemy(coords: Vector2i, character_type: bool):
	print(map_obj[coords[0]][coords[1]])
	for obj in map_obj[coords[0]][coords[1]]:
		print("has enemy", coords, obj)
		if obj.data.is_player_character != character_type:
			return true
	return false

func get_enemy(coords: Vector2i, character_type: bool):
	for obj in map_obj[coords[0]][coords[1]]:
		if obj.data.is_player_character != character_type:
			return obj
	return null

func _process(delta: float) -> void:
	pass

enum SelectionPhase{
	MOVE,
	ATACK,
	NONE
}

var selection_phase: SelectionPhase

func set_selection_phase(phase: SelectionPhase):
	selection_phase = phase

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var tile_mouse_pos = local_to_map(mouse_pos)
		
		if tile_mouse_pos in modulated_cells and selection_phase == SelectionPhase.MOVE:
			selection_phase = SelectionPhase.NONE
			TurnHUD.move_to_tile(tile_mouse_pos)
			TurnHUD.update_ui(TurnHUD.current_character)
		if tile_mouse_pos in modulated_cells and selection_phase == SelectionPhase.ATACK:
			selection_phase = SelectionPhase.NONE
			TurnHUD.make_atack(tile_mouse_pos)
		print("TileMapClicked", tile_mouse_pos)

# Dictionary to store tile positions and their corresponding modulation colors
var modulated_cells := {}
#
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Determine if the tile at 'coords' should have its data updated
	#print("hi2")
	return modulated_cells.has(coords)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	# Apply the modulation color to the specified tile
	print("hi")
	tile_data.modulate = modulated_cells.get(coords, Color(1, 1, 1, 1))
