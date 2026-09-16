extends Area2D

@export var triggers : Array[PackedScene]
@export var speed = 1

var direction : Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += speed * direction


func _on_body_entered(body: Node2D) -> void:
	if body is player and direction != Vector2(0,0):
		body._die()
	else:
		direction = Vector2(0,0)
