extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Node2D.hide()
	Inventory.potion_drunk.connect(_cheer)

func _cheer() -> void:
	$AudioStreamPlayer2D.play()
	$Node2D.show()
	play("fly in")
	
	
