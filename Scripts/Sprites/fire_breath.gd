extends Area2D
class_name FireBreathHitbox

func _ready() -> void:
	add_to_group("fire_damage")
	monitoring = false
