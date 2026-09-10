extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $Thomas_Foolery
@onready var _last_costume = -1

@export var costumes: Array[String] = ["Cutie", "Downey", "Split", "Stool", "Webby", "Wierd", "Womp"]   # names of the AnimatedSprite2D animations
@export var movements_in: Array[String] = ["Blink_in", "Slide in", "slam in", "slide up in"] 
@export var movements_out: Array[String] = ["Blink out", "Slide out", "spin out"] 
@export var hold_time: float = 3.0

var _index = -1
	

func _ready() -> void:
	var name = costumes.pick_random()
	sprite.play(name)
	
	await get_tree().create_timer(3.0).timeout
	_cycle()


func _cycle() -> void:
	while true:
		
		# play "out", await it
		
		anim.play(movements_out.pick_random())
		await anim.animation_finished
		
		# swap costume to a random one
		
		sprite.hide()
		sprite.rotation_degrees = 0
		sprite.scale.x = 0.447
		sprite.scale.y = 0.447
		sprite.play(_pick_costume())
		
		# play a random movement, await it
		
		var move_in = movements_in.pick_random()
		anim.play(move_in)
		anim.advance(0.0)     # apply frame 0 right now
		sprite.show()
		await anim.animation_finished
		
		# await hold_time
		
		await get_tree().create_timer(3.0).timeout
	var _last_costume := -1

func _pick_costume() -> String:
	if costumes.size() <= 1:
		return costumes[0]
	var i := randi() % costumes.size()
	if i == _last_costume:
		i = (i + 1) % costumes.size()
	_last_costume = i
	return costumes[i]
