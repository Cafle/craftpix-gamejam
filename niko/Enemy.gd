extends CharacterBody2D
class_name Enemy


enum State { IDLE, WANDER, CHASE, ATTACK, DEAD }


@export_group("Movement")
@export var move_speed: float = 60.0
@export var chase_speed: float = 110.0
@export var wander_radius: float = 80.0
@export var gravity: float = 20.0
@export var jump_force: float = 260.0
@export var jump_trigger_height: float = 65.0
@export var jump_range: float = 120.0
@export var jump_cooldown: float = 1.5


@export_group("Combat")
@export var hitpoints: int = 3
@export var attack_damage: int = 1
@export var attack_range: float = 32.0
@export var attack_release_ratio: float = 1.3
@export var attack_cooldown: float = 1.0
@export var attack_active_frame_start: int = 4
@export var attack_active_frame_end: int = 5
@export var fire_dps: int = 10
@export var fire_tick_interval: float = 0.1
@export var explosion_scene: PackedScene


@onready var body_shape: CollisionShape2D = $BodyShape
@onready var hurtbox: Area2D = $Hurtbox
@onready var detection_area: Area2D = $DetectionArea
@onready var visual: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AnimatedSprite2D/AttackHitbox
@onready var attack_hitbox_shape: CollisionShape2D = $AnimatedSprite2D/AttackHitbox/CollisionShape2D


var state: State = State.WANDER
var player_ref: Node2D = null
var spawn_point: Vector2
var wander_target: Vector2
var wander_wait_timer: float = 0.0
var attack_timer: float = 0.0
var jump_timer: float = 0.0
var is_attacking: bool = false
var _fire_sources: int = 0
var _fire_tick_timer: float = 0.0
var _has_hit_this_swing: bool = false
var _intent_velocity_x: float = 0.0


func _ready() -> void:
	spawn_point = global_position

	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	hurtbox.area_exited.connect(_on_hurtbox_area_exited)

	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)

	attack_hitbox.monitoring = true
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	visual.frame_changed.connect(_on_attack_frame_changed)

	_pick_new_wander_target()


func _physics_process(delta: float) -> void:
	attack_hitbox_shape.disabled = not is_attacking

	if state == State.DEAD:
		return

	_process_fire(delta)
	if state == State.DEAD:
		return

	if not is_on_floor():
		velocity.y += gravity
	else:
		velocity.y = 0

	attack_timer = maxf(attack_timer - delta, 0.0)
	jump_timer = maxf(jump_timer - delta, 0.0)

	match state:
		State.IDLE:
			_idle(delta)
		State.WANDER:
			_wander()
		State.CHASE:
			_chase()
		State.ATTACK:
			_attack()

	_intent_velocity_x = velocity.x

	move_and_slide()

	_update_facing()
	_update_animation()


func _idle(delta: float) -> void:
	velocity.x = 0
	wander_wait_timer -= delta
	if wander_wait_timer <= 0.0:
		state = State.WANDER
		_pick_new_wander_target()


func _wander() -> void:
	var to_target_x := wander_target.x - global_position.x
	if absf(to_target_x) < 5.0:
		velocity.x = 0
		wander_wait_timer = randf_range(1.0, 2.5)
		state = State.IDLE
		return
	velocity.x = signf(to_target_x) * move_speed


func _chase() -> void:
	if not is_instance_valid(player_ref):
		_return_to_wander()
		return

	var to_player := player_ref.global_position - global_position

	if absf(to_player.x) <= attack_range:
		state = State.ATTACK
		is_attacking = false
		return

	velocity.x = signf(to_player.x) * chase_speed
	_try_jump(to_player)


func _attack() -> void:
	if not is_instance_valid(player_ref):
		_return_to_wander()
		return

	var to_player_x := player_ref.global_position.x - global_position.x

	if absf(to_player_x) > attack_range * attack_release_ratio:
		state = State.CHASE
		is_attacking = false
		return

	velocity.x = 0

	if not is_attacking and attack_timer <= 0.0:
		_start_swing()


func _try_jump(to_player: Vector2) -> void:
	if not is_on_floor() or jump_timer > 0.0:
		return
	if to_player.y <= -jump_trigger_height and absf(to_player.x) <= jump_range:
		velocity.y = -jump_force
		jump_timer = jump_cooldown


func _return_to_wander() -> void:
	player_ref = null
	state = State.WANDER
	is_attacking = false
	_pick_new_wander_target()


func _pick_new_wander_target() -> void:
	wander_target = spawn_point + Vector2(randf_range(-wander_radius, wander_radius), 0.0)


func _start_swing() -> void:
	is_attacking = true
	attack_timer = attack_cooldown
	_has_hit_this_swing = false
	visual.play("running_attack")

	if not visual.animation_finished.is_connected(_on_attack_finished):
		visual.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)


func _on_attack_frame_changed() -> void:
	if not is_attacking or visual.animation != "running_attack":
		return
	if _has_hit_this_swing:
		return

	var f := visual.frame
	if f < attack_active_frame_start or f > attack_active_frame_end:
		return

	for body in attack_hitbox.get_overlapping_bodies():
		_try_hit(body)


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if not is_attacking or _has_hit_this_swing:
		return
	var f := visual.frame
	if f < attack_active_frame_start or f > attack_active_frame_end:
		return
	_try_hit(body)


func _try_hit(body: Node2D) -> void:
	if _has_hit_this_swing or state == State.DEAD:
		return
	if not (body is player):
		return

	_has_hit_this_swing = true
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
	else:
		push_warning("Enemy hit %s, which has no take_damage()." % body.name)


func _on_attack_finished() -> void:
	if visual.animation != "running_attack":
		return
	is_attacking = false


func _update_facing() -> void:
	if (state == State.CHASE or state == State.ATTACK) and is_instance_valid(player_ref):
		var dx := player_ref.global_position.x - global_position.x
		if absf(dx) > 2.0:
			visual.scale.x = 1.0 if dx > 0.0 else -1.0
	elif absf(_intent_velocity_x) > 1.0:
		visual.scale.x = 1.0 if _intent_velocity_x > 0.0 else -1.0


func _update_animation() -> void:
	var target := "idle"

	match state:
		State.IDLE:
			target = "idle"
		State.WANDER:
			target = "walk" if absf(velocity.x) > 1.0 else "idle"
		State.CHASE:
			target = "run"
		State.ATTACK:
			target = "running_attack" if is_attacking else "idle"
		State.DEAD:
			target = "death"

	if state != State.DEAD and state != State.ATTACK \
			and not is_on_floor() and velocity.y < 0.0:
		target = "jump"

	if visual.animation != target:
		visual.play(target)


func _flash_hit() -> void:
	visual.modulate = Color(1.0, 0.4, 0.4)
	create_tween().tween_property(visual, "modulate", Color.WHITE, 0.15)


func _process_fire(delta: float) -> void:
	if _fire_sources <= 0:
		return

	_fire_tick_timer -= delta
	if _fire_tick_timer > 0.0:
		return

	_fire_tick_timer = fire_tick_interval
	_take_hit(maxi(int(fire_dps * fire_tick_interval), 1))


func _take_hit(amount: int = 1) -> void:
	if state == State.DEAD:
		return

	hitpoints -= amount
	if hitpoints <= 0:
		state = State.DEAD
		is_attacking = false
		attack_hitbox_shape.disabled = true
		_die()
	else:
		_flash_hit()


func _die() -> void:
	visual.play("death")
	set_physics_process(false)

	if explosion_scene:
		var fx := explosion_scene.instantiate()
		fx.global_position = global_position
		get_parent().add_child(fx)

	await visual.animation_finished
	queue_free()


func _on_detection_body_entered(body: Node2D) -> void:
	if body is player and state != State.DEAD:
		player_ref = body
		state = State.CHASE


func _on_detection_body_exited(body: Node2D) -> void:
	if body == player_ref and state != State.DEAD:
		_return_to_wander()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if state == State.DEAD:
		return
	if body is player and body.has_method("is_slamming") and body.is_slamming():
		_take_hit(hitpoints)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if state == State.DEAD:
		return
	if area.is_in_group("fire_damage"):
		_fire_sources += 1
		_fire_tick_timer = 0.0


func _on_hurtbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("fire_damage"):
		_fire_sources = maxi(_fire_sources - 1, 0)
