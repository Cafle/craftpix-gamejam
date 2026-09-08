extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var path = "res://Scenes/Level/"+ str(LevelSelect.current_level) + ".tscn"
	var level = load(path).instantiate()
	$SubViewport.add_child(level)
	$Sprite2D.texture = $SubViewport.get_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
