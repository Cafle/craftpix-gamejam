extends CharacterBody2D
class_name NPCEntity

enum NPCType { WALKER, BARTENDER }
enum State { IDLE, WANDER, CHASE }

@export var npc_type: NPCType = NPCType.WALKER

@export_group("Movement")
@export var move_speed: float = 60.0
@export var chase_speed: float = 110.0
@export var wander_radius: float = 80.0
@export var gravity: float = 20.0

@export_group("Combat")
@export var explosion_scene: PackedScene

@onready var body_shape: CollisionShape2D = $BodyShape
@onready var hurtbox: Area2D = $Hurtbox
@onready var detection_area: Area2D = $DetectionArea
@onready var visual: AnimatedSprite2D = $AnimatedSprite2D

var state: State = State.WANDER
var player_ref: Node2D = null
var spawn_point: Vector2
var wander_target: Vector2

func _ready() -> void:
	spawn_point = global_position

	# One-way collision: player can pass through from below,
	# but rests on top if they land on the NPC.
	body_shape.one_way_collision = true
	body_shape.one_way_collision_margin = 5.0

	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	if npc_type == NPCType.BARTENDER:
		detection_area.body_entered.connect(_on_detection_body_entered)
		detection_area.body_exited.connect(_on_detection_body_exited)
	else:
		# Walkers never chase - detection area is unused for them.
		detection_area.monitoring = false

	_pick_new_wander_target()

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity
	else:
		velocity.y = 0

	match state:
		State.IDLE:
			velocity.x = 0
		State.WANDER:
			_wander()
		State.CHASE:
			_chase()

	move_and_slide()
	_update_facing()
	_update_animation()

func _wander() -> void:
	var to_target_x := wander_target.x - global_position.x
	if abs(to_target_x) < 5.0:
		_pick_new_wander_target()
	velocity.x = signf(to_target_x) * move_speed

func _chase() -> void:
	if not is_instance_valid(player_ref):
		state = State.WANDER
		_pick_new_wander_target()
		return
	var to_player_x := player_ref.global_position.x - global_position.x
	velocity.x = signf(to_player_x) * chase_speed

func _pick_new_wander_target() -> void:
	var offset_x := randf_range(-wander_radius, wander_radius)
	wander_target = spawn_point + Vector2(offset_x, 0)

func _update_facing() -> void:
	if velocity.x != 0:
		visual.scale.x = -1 if velocity.x > 0 else 1

func _update_animation() -> void:
	var target_animation := "idle"
	match state:
		State.IDLE:
			target_animation = "idle"
		State.WANDER:
			target_animation = "walk" if abs(velocity.x) > 1.0 else "idle"
		State.CHASE:
			target_animation = "run" if visual.sprite_frames.has_animation("run") else "walk"

	if visual.animation != target_animation:
		visual.play(target_animation)

func _on_detection_body_entered(body: Node2D) -> void:
	if body is player:
		player_ref = body
		state = State.CHASE

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		state = State.WANDER
		_pick_new_wander_target()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is player and body.is_slamming():
		_explode()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("fire_damage"):
		_explode()

func _explode() -> void:
	visual.play("death")
	set_physics_process(false)  # stop moving while dying
	if explosion_scene:
		var fx := explosion_scene.instantiate()
		fx.global_position = global_position
		get_parent().add_child(fx)
	await visual.animation_finished
	queue_free()
