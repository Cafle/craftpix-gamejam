extends Area2D

signal flood_triggered()

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is player:
		print("YO")
		flood_triggered.emit()
		set_deferred("monitoring", false)
