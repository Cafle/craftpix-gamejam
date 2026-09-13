extends Node2D

@export var spawn_me : PackedScene
@export var time_between : int = 10
@export var max : int = 20

var spawning = false

var count : int
var scount : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	count = 0
	if spawn_me:
		spawning = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		if spawning and count <= 0 and scount <= max:
			
			var clone = spawn_me.instantiate()
			clone.position = position
			add_sibling(clone)
			count = time_between
			scount =1
		else:
			count -= 1
