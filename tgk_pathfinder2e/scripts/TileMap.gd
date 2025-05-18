extends TileMap

# Dictionary that holds modulated colors per cell
var modulated_cells := {}

# Called automatically by Godot to determine if a tile needs runtime update
func _use_tile_data_runtime_update(layer: int, coords: Vector2i) -> bool:
	return modulated_cells.has(coords)

# Called to actually apply the modulate override
func _tile_data_runtime_update(layer: int, coords: Vector2i, tile_data: TileData) -> void:
	
	tile_data.modulate = modulated_cells.get(coords, Color(1, 1, 1, 1))

# Optional utility: highlight a set of cells with a given color
func highlight_tiles(cells: Array, color: Color = Color(0.2, 0.8, 1.0, 0.5)):
	for cell in cells:
		modulated_cells[cell] = color
	queue_redraw()

# Optional utility: clear all modulations
func clear_highlights():
	modulated_cells.clear()
	queue_redraw()
