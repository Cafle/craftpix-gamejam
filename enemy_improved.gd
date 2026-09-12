extends CharacterBody2D

@export var StartDir := 1
@export var attack_range := 30.0
@export var ledge_pause := 0.4

@onready var pivot: Marker2D = $pivot
@onready var sight: Area2D = $pivot/Sight
@onready var walls = $pivot/Walls
@onready var kill = $pivot/Kill

@onready var anim: AnimatedSprite2D = $pivot/Animation
@onready var ground: RayCast2D = $pivot/Ground_check
@onready var jumping = false

const SPEED = 330.0
const ACCELERATION = 300.0
const FRICTION = 900.0

var player_node: Node2D = null
var found := false
var dir := 1


func _ready() -> void:
	sight.body_entered.connect(_found_player)
	dir = StartDir
	
	_cycle()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumping = false
	move_and_slide()
	_face()


func _cycle() -> void:
	await get_tree().physics_frame
	while is_inside_tree():
		await get_tree().physics_frame
		if found and is_instance_valid(player_node):
			await _chase()
		else:
			await _patrol()


func _patrol() -> void:
	
	ground.force_raycast_update()
	
	if not ground.is_colliding():
		print("detected ledge")
		velocity.x = 0
		move_and_slide()
		_chill()
		await get_tree().create_timer(ledge_pause).timeout
		dir *= -1
		_face()
		print ("turning around")
		await _face()
		await get_tree().create_timer(ledge_pause).timeout
		
	else:
		_walk(dir)
	if walls.is_colliding():
		print("wall")
		if walls.get_collider() is TileMapLayer:
			print("detected wall, turning around")
			dir *= -1
	await get_tree().physics_frame


func _chase() -> void:
	if is_inside_tree():
		var to_player_x := player_node.global_position.x - global_position.x
		var to_player_y := player_node.global_position.y - global_position.y
		dir = signi(int(to_player_x))
		_face()
		
		if absf(to_player_x) < attack_range and absf(to_player_y) < attack_range:
			velocity.x = 0
			anim.play("running_attack")
			await anim.animation_finished
			if is_instance_valid(player_node) and player_node.has_method("_die"):
				print("kill")
				#player_node._die()
		else:
			_run(signi(int(to_player_x)))
			await get_tree().physics_frame
			if to_player_y < -30 and not jumping:
				jumping = true
				anim.play("jump")
				velocity.y = -420
		
		
	if not ground.is_colliding() and not jumping:
		jumping = true
		anim.play("jump")
		velocity.y = -420


func _chill() -> void:
	anim.play("idle")
	velocity.x = 0
	#velocity.x = move_toward(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())


func _walk(d: int) -> void:
	anim.play("walk")
	velocity.x = move_toward(velocity.x, d * SPEED / 2.0, ACCELERATION)


func _run(d: int) -> void:
	anim.play("run")
	velocity.x = move_toward(velocity.x, d * SPEED, ACCELERATION)


func _face() -> void:
	pivot.scale.x = dir
		#scales the vectors with it


func _found_player(body) -> void:
	if body is player:
		found = true
		player_node = body
