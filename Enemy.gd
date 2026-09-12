extends CharacterBody2D
class_name Enemy

enum State { IDLE, WANDER, CHASE, ATTACK, DEAD }

@export_group("Movement")
@export var move_speed: float = 60.0
@export var chase_speed: float = 110.0
@export var wander_radius: float = 80.0
@export var gravity: float = 20.0

@export_group("Combat")
@export var hitpoints: int = 3
@export var attack_damage: int = 1
@export var attack_range: float = 24.0
@export var attack_cooldown: float = 1.0
@export var fire_dps: int = 10
@export var fire_tick_interval: float = 0.1
@export var explosion_scene: PackedScene
## Frame range (inclusive) of the "attack"/"running_attack" animation during
## which the hitbox is actually live. Attack anim is 5 frames (0-4); hitbox
## spawns only on the final frame where the weapon connects.
@export var attack_active_frame_start: int = 4
@export var attack_active_frame_end: int = 4

@onready var body_shape: CollisionShape2D = $BodyShape
@onready var hurtbox: Area2D = $Hurtbox
@onready var detection_area: Area2D = $DetectionArea
@onready var visual: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AnimatedSprite2D/AttackHitbox

var state: State = State.WANDER
var player_ref: Node2D = null
var spawn_point: Vector2
var wander_target: Vector2
var wander_wait_timer: float = 0.0
var attack_timer: float = 0.0
var is_attacking: bool = false

var in_fire: bool = false
var fire_tick_timer: float = 0.0

var _has_hit_this_swing: bool = false

func _ready() -> void:
	spawn_point = global_position

	body_shape.one_way_collision = true
	body_shape.one_way_collision_margin = 5.0

	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	hurtbox.area_exited.connect(_on_hurtbox_area_exited)

	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)

	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	visual.frame_changed.connect(_on_attack_frame_changed)

	_pick_new_wander_target()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	if in_fire:
		fire_tick_timer -= delta
		if fire_tick_timer <= 0.0:
			fire_tick_timer = fire_tick_interval
			var tick_damage := int(fire_dps * fire_tick_interval)
			_take_hit(max(tick_damage, 1))
			if state == State.DEAD:
				return

	if not is_on_floor():
		velocity.y += gravity
	else:
		velocity.y = 0

	if attack_timer > 0.0:
		attack_timer -= delta

	match state:
		State.IDLE:
			velocity.x = 0
			wander_wait_timer -= delta
			if wander_wait_timer <= 0.0:
				state = State.WANDER
				_pick_new_wander_target()
		State.WANDER:
			_wander()
		State.CHASE:
			_chase()
		State.ATTACK:
			_attack()

	move_and_slide()
	_update_facing()
	_update_animation()

func _wander() -> void:
	var to_target_x := wander_target.x - global_position.x
	if abs(to_target_x) < 5.0:
		velocity.x = 0
		wander_wait_timer = randf_range(1.0, 2.5)
		state = State.IDLE
		return
	velocity.x = signf(to_target_x) * move_speed

func _chase() -> void:
	if not is_instance_valid(player_ref):
		state = State.WANDER
		_pick_new_wander_target()
		return

	var to_player_x := player_ref.global_position.x - global_position.x
	if abs(to_player_x) <= attack_range:
		state = State.ATTACK
		is_attacking = false
		return

	velocity.x = signf(to_player_x) * chase_speed

func _attack() -> void:
	if not is_instance_valid(player_ref):
		state = State.WANDER
		_pick_new_wander_target()
		return

	var to_player_x := player_ref.global_position.x - global_position.x
	if abs(to_player_x) > attack_range:
		state = State.CHASE
		is_attacking = false
		return

	if not is_attacking and attack_timer <= 0.0:
		is_attacking = true
		attack_timer = attack_cooldown
		_has_hit_this_swing = false
		visual.play("running_attack")
		if not visual.animation_finished.is_connected(_on_attack_finished):
			visual.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
		# Actual damage is applied in _on_attack_frame_changed(), gated to
		# attack_active_frame_start/end, and in _on_attack_hitbox_body_entered().

	velocity.x = 0
		# This keeps the hit timed to the frame the weapon visually connects
		# instead of firing the instant the swing starts.

func _on_attack_frame_changed() -> void:
	if not is_attacking or visual.animation != "running_attack":
		attack_hitbox.monitoring = false
		return
	var f := visual.frame
	var should_be_active := f >= attack_active_frame_start and f <= attack_active_frame_end
	var was_active := attack_hitbox.monitoring
	attack_hitbox.monitoring = should_be_active
	# Area2D only emits body_entered on a NEW overlap, so a body already
	# standing inside the hitbox when it switches on wouldn't otherwise
	# trigger a hit. Catch that case manually right when it opens.
	if should_be_active and not was_active:
		for body in attack_hitbox.get_overlapping_bodies():
			_on_attack_hitbox_body_entered(body)

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if _has_hit_this_swing:
		return
	if body is player and state != State.DEAD:
		_has_hit_this_swing = true
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)

func _on_attack_finished() -> void:
	is_attacking = false
	attack_hitbox.monitoring = false

func _pick_new_wander_target() -> void:
	var offset_x := randf_range(-wander_radius, wander_radius)
	wander_target = spawn_point + Vector2(offset_x, 0)

func _update_facing() -> void:
	if velocity.x != 0:
		visual.scale.x = 1 if velocity.x > 0 else -1

func _update_animation() -> void:
	var target_animation := "idle"
	match state:
		State.IDLE:
			target_animation = "idle"
		State.WANDER:
			target_animation = "walk" if abs(velocity.x) > 1.0 else "idle"
		State.CHASE:
			target_animation = "run"
		State.ATTACK:
			target_animation = "running_attack" if is_attacking else "idle"
		State.DEAD:
			target_animation = "death"

	if visual.animation != target_animation:
		visual.play(target_animation)

func _on_detection_body_entered(body: Node2D) -> void:
	if body is player and state != State.DEAD:
		player_ref = body
		state = State.CHASE

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		if state != State.DEAD:
			state = State.WANDER
			_pick_new_wander_target()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is player and body.is_slamming():
		_take_hit(hitpoints)  # slam kills outright

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("fire_damage"):
		in_fire = true
		fire_tick_timer = 0.0  # damage immediately on contact

func _on_hurtbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("fire_damage"):
		in_fire = false

func _take_hit(amount: int = 1) -> void:
	hitpoints -= amount
	if hitpoints <= 0:
		state = State.DEAD
		is_attacking = false
		attack_hitbox.monitoring = false
		_die()
	else:
		_flash_hit()

func _flash_hit() -> void:
	visual.modulate = Color(1, 0.4, 0.4)
	var tween := create_tween()
	tween.tween_property(visual, "modulate", Color.WHITE, 0.15)

func _die() -> void:
	visual.play("death")
	set_physics_process(false)
	if explosion_scene:
		var fx := explosion_scene.instantiate()
		fx.global_position = global_position
		get_parent().add_child(fx)
	await visual.animation_finished
	queue_free()
