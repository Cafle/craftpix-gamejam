extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WinObject/Sprite2D/Area2D.body_entered.connect(_win)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _win(body: CharacterBody2D) -> void:
	# THIS FUNCTION WAS THE ROOT CAUSE of progress not saving.
	# unlockLevel() was never being called from anywhere in the
	# game, so HUL never changed and _save() never triggered —
	# regardless of whether SaveManager itself worked correctly.

	var next_level := LevelSelect.current_level + 1
	# NEW: compute this once instead of repeating
	# "LevelSelect.current_level + 1" in three places below —
	# also avoids current_level drifting mid-function if it were
	# updated before all three uses.

	LevelSelect.unlockLevel(next_level)
	# NEW — this is the actual fix. This line was completely
	# missing before. Bumps HUL if next_level is higher, and
	# triggers the save via LevelSelect._save().

	LevelSelect.current_level = next_level
	# NEW. Previously current_level was set once at declaration
	# (= 1) and never updated again anywhere, so it never reflected
	# real progress past the very first level.

	LevelSelect._playSong(next_level)
	# UNCHANGED in behavior, now just using the next_level variable.

	get_tree().call_deferred("change_scene_to_file", LevelSelect.loadLevel(next_level))
	# UNCHANGED in behavior, now just using the next_level variable.

func _lost(body: CharacterBody2D, ani : int) -> void :
	# UNCHANGED.
	pass
