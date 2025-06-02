extends Area2D

@onready var sprite_2d: Sprite2D = $".."
@onready var character_node: Node2D = $"../.."

#func on_mouse_enter():
	#print("enter mouse")

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		print("Character selected")
		#character_node.select()
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#connect("mouse_entered", self, )
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
