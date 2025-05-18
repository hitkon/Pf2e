extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Dictionary to store tile positions and their corresponding modulation colors
var modulated_cells := {
	Vector2i(10, 10): Color(1, 0, 0, 0.5),  # Semi-transparent red
	Vector2i(15, 15): Color(0, 1, 0, 0.5),  # Semi-transparent green
	Vector2i(20, 20): Color(0, 0, 1, 0.5)   # Semi-transparent blue
}

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Determine if the tile at 'coords' should have its data updated
	return modulated_cells.has(coords)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	# Apply the modulation color to the specified tile
	tile_data.modulate = modulated_cells.get(coords, Color(1, 1, 1, 1))
