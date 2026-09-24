extends Node2D


@export var spawn_me : PackedScene
@export var or_duplicate : Node2D
@export var time_between : int = 10
@export var max : int = 20

@export_category("Screenlock")
@export var screen_lock = false
@export var bind = Node2D
@export var offset_x : float
@export var offset_y : float

var spawning = false

var count : int
var scount : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	count = 0
	if spawn_me or or_duplicate:
		spawning = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if screen_lock:
		if bind:
			position = bind.position
			position.x += offset_x
			position.y += offset_y
	if or_duplicate:
		print(or_duplicate)
		if spawning and count <= 0 and scount <= max:
			var clone = or_duplicate.duplicate()
			clone.position = position
			add_sibling(clone)
			count = time_between
			scount += 1
		else:
			count -= 1
	else:
		if spawning and count <= 0 and scount <= max:
			
			var clone = spawn_me.instantiate()
			clone.position = position
			add_sibling(clone)
			count = time_between
			scount += 1
		else:
			count -= 1
