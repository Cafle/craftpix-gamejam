extends Area2D

class_name KillObject

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D):
	if body is player:
		get_parent().get_parent()._lost(1)
