extends Area2D

@export_group("if timer 0 not repeating, otherwise set second value")
@export var timer = 0
@export var max_shots = 0

signal shoot()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if timer != 0:
		await get_tree().create_timer(timer).timeout
		shoot.emit()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	shoot.emit()
