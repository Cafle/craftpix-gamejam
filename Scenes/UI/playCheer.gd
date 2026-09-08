extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Node2D.hide()
	Inventory.potion_drunk.connect(_cheer)

func _cheer() -> void:
	$Node2D/bg.material.set_shader_parameter("new_color1", Inventory.potions[0].color.darkened(0.4))
	$Node2D/bg.material.set_shader_parameter("new_color2", Inventory.potions[0].color.darkened(-0.2))
	$Node2D/bg.material.set_shader_parameter("new_color3", Inventory.potions[0].color)
	$AudioStreamPlayer2D.play()
	$Node2D.show()
	play("fly in")
	
	
