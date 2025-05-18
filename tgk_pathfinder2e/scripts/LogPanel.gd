extends Panel

@onready var log_list = $ScrollContainer/LogList
@onready var camera = get_node("/root/Main/Camera2D")  # adjust if needed

func _process(delta):
	# Pin to bottom-left of camera
	var screen_center = camera.get_screen_center_position()
	var offset = Vector2(-795, 295)  # adjust offsets
	global_position = screen_center + offset

func add_log_entry(text: String):
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	log_list.add_child(label)

	await get_tree().process_frame
	$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scroll_bar().max_value
