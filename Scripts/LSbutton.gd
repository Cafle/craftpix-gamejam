extends Button

var level: int = 1
var locked: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level = get_index()+1
	text = str(level)
	locked = level > LevelSelect.HUL
	modulate.a = 0.5 if locked else 1.0

func _pressed() -> void:
	if !locked:
		LevelSelect.current_level = level
		LevelSelect._playSong(level)
		get_tree().call_deferred("change_scene_to_file", LevelSelect.loadLevel(level))
