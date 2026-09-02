extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WinObject/Sprite2D/Area2D.body_entered.connect(_win)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _win(body: CharacterBody2D) -> void:
	LevelSelect._playSong(LevelSelect.current_level + 1)
	get_tree().call_deferred("change_scene_to_file", LevelSelect.loadLevel(LevelSelect.current_level + 1))
