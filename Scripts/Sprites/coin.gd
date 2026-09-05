extends Node2D

@onready var area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(_touched)
	pass # Replace with function body.

func _touched(body : Node2D) -> void:
	LevelSelect.Coins += 1
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
