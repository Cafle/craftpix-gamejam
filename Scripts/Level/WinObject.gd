extends Node2D

func _ready():
	$Sprite2D/Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is player:
		get_parent()._win()
