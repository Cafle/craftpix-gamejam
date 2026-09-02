extends CharacterBody2D

# movement variables - tweak these to adjust feel
@export var speed: float = 300
@export var coyoteFrames: int = 5
@export var jump_force: float = 400
@export var terminal_velocity: float = 2000
@export var wall_slide_velocity: float = 100
@export var gravity: float = 20
@export var lerp_factor: float = 1
@export var wall_jump_frames: int = 10
@export var shorthop_factor: float = -300
@export var fall_multiplier: float = 1.5
@export var nudgeularity: int = 10
@export var jump_buffer_timer: float = 100.0
@export var chonkiness: float = 0.05

# coyote time + jump buffer variables

@onready var jbuffer: int = 0
@onready var coyote: int = 0
@onready var wjframe: int = 0

func _physics_process(delta):
	# apply gravity
	var direction = Input.get_axis("ui_left", "ui_right")
	if is_on_floor():
		coyote = 0
		velocity.y = 0
		
	elif (coyote >= coyoteFrames):
		if velocity.y < terminal_velocity and not (is_on_wall_only() and direction and velocity.y>0):
			velocity.y += gravity * (fall_multiplier if velocity.y > 0 else 1.0)
		elif is_on_wall_only() && direction:
			velocity.y = wall_slide_velocity
		else:
			velocity.y = terminal_velocity
	else:
		coyote +=1
	
	# when jump is pressed in the air
	if Input.is_action_just_pressed("ui_up"):
		jbuffer = jump_buffer_timer

	# count it down every frame
	if jbuffer > 0:
		jbuffer -= delta
	# handle jump buffer
	var jump_condition = (is_on_floor() or (is_on_wall_only() and direction)
	or coyote<coyoteFrames or (is_on_floor() and 
	jbuffer > 0))
	# handle jump input

	
	if (jump_condition && Input.is_action_just_pressed("ui_up")) or (is_on_floor() and jbuffer > 0 and Input.is_action_pressed("ui_up")):
		jbuffer = 0
		velocity.y = jump_force * -1
		if is_on_wall_only() && direction:
			wjframe = wall_jump_frames
			velocity.x = speed * -direction
	
	if Input.is_action_just_released("ui_up") && velocity.y < 0:
		velocity.y -= shorthop_factor
		if velocity.y > 0:
			velocity.y = 0
	
	
	
	if wjframe == 0:
		velocity.x = lerp(velocity.x, speed * direction, lerp_factor)
	else:
		wjframe -= 1
	
	var y_vel = velocity.y
	
	
	var was_floored = is_on_floor()
	
	move_and_slide()
	
	if !was_floored && is_on_floor() && y_vel > 1200:
		var stretchMe = $AnimatedSprite2D.scale.y
		var stretchLeg = $Legs.scale.y
		$AnimatedSprite2D.scale.y /= 10
		$AnimatedSprite2D.position.y += 50
		$Legs.scale.y /= 10
		$Legs.position.y += 50
		
		camera_shake(chonkiness * y_vel, 0.3)
		
		$AnimatedSprite2D.scale.y = stretchMe
		$AnimatedSprite2D.position.y -= 50
		$Legs.scale.y = stretchLeg
		$Legs.position.y -= 50
	
	if is_on_ceiling() && y_vel < 0:
		#try right
		for i in range(1, nudgeularity): 
			if not move_and_collide(Vector2(i, -0.1), true):
				position.x += i
				velocity.y = y_vel
				break
			#if still colliding?
			#try left
			elif not move_and_collide(Vector2(-i, -0.1), true):
				position.x -= i
				velocity.y = y_vel
				break


func camera_shake(strength: float, duration: float = 0.3):


	var camera = $Camera2D
	var original_pos = camera.position
	var tween = create_tween()
	var shakes = 8
	for i in shakes:
		var offset = Vector2(0, strength if i % 2 == 0 else -strength)
		tween.tween_property(camera, "position", original_pos + offset, duration / shakes)
	tween.tween_property(camera, "position", original_pos, duration / shakes)
	
