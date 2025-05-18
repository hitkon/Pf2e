extends TileMapLayer

var TurnHUD

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(TileMapLayer.has_method("queue_redraw"))
	TurnHUD = get_node("/root/Main/TurnHUD") 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var tile_mouse_pos = local_to_map(mouse_pos)
		if tile_mouse_pos in modulated_cells:
			TurnHUD.move_to_tile(tile_mouse_pos)
			TurnHUD.update_ui(TurnHUD.current_character)
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
