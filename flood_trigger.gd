extends Area2D

@onready var flood_water: Node2D = %FloodWater

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is player:
		print("coming for you")
		flood_water.start_flooding()
		set_deferred("monitoring", false)
