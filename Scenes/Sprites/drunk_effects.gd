extends CanvasLayer


# Called when the node enters the scene tree for the first time.

func _ready() -> void:	
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$"../Camera2D".rotation_degrees = 180
	var mat = $yes.material
	if Inventory.intoxication >= 2:
		var t := Time.get_ticks_msec() * 0.001
		mat.set_shader_parameter("strength", 1.0)
		mat.set_shader_parameter("offset", sin(t * 4) * 0.008)
		mat.set_shader_parameter("coffset", cos(t * 4) * 0.008)
	else:
		mat.set_shader_parameter("strength", 0.0)
	
	if Inventory.intoxication >= 3:
		var t := Time.get_ticks_msec() * 0.001
		mat.set_shader_parameter("offset", sin(t * 4) * 0.08)
		mat.set_shader_parameter("coffset", cos(t * 4) * 0.08)
		mat.set_shader_parameter("strength", 4.0)
		$"../Camera2D".rotation_degrees =  180 + (sin(t) *10)
	
