extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(TileMapLayer.has_method("queue_redraw"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

# Dictionary to store tile positions and their corresponding modulation colors
var modulated_cells := {}
#
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	# Determine if the tile at 'coords' should have its data updated
	#print("hi2")
	return modulated_cells.has(coords)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	# Apply the modulation color to the specified tile
	#print("hi")
	tile_data.modulate = modulated_cells.get(coords, Color(1, 1, 1, 1))
