extends Node2D

@export var dart : PackedScene
@export var signal_objects : Array [Node2D]
@export var direction : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if signal_objects:
		for i in signal_objects:
			i.shoot.connect(_shoot)

func _shoot() -> void:
	var newDart = dart.instantiate()
	newDart.position = position
	newDart.direction = direction
	add_sibling(newDart)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
