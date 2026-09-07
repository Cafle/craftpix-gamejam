extends AnimatedSprite2D

@export var col1: Color
@export var col2: Color
@export var col3: Color
@export var col4: Color
@export var col5: Color
@export var col6: Color
@export var col7: Color
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	material.set_shader_parameter("key_color", col1)
	material.set_shader_parameter("skin_color", Color(0.879, 0.715, 0.594, 1.0))
	material.set_shader_parameter("key_color", col2)
	material.set_shader_parameter("skin_color", Color(0.879, 0.715, 0.594, 1.0))
