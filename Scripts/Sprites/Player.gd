extends CharacterBody2D

class_name player
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
@export var slide_cooldown: int = 70

# coyote time + jump buffer variables

@onready var jbuffer: int = 0
@onready var coyote: int = 0
@onready var wjframe: int = 0
@onready var roll_vel = 6 
@onready var slideFrame = 0
#animating 

@onready var animator = $AnimatedSprite2D
@onready var roll_or_slide = ""


func is_wall_jump_valid() -> bool:
	if $AnimatedSprite2D/upWall.is_colliding() && $AnimatedSprite2D/downWall.is_colliding() && is_on_wall_only():
		$AnimatedSprite2D/upWall.force_raycast_update()
		$AnimatedSprite2D/downWall.force_raycast_update()
		var up_collider = $AnimatedSprite2D/upWall.get_collider()
		var down_collider = $AnimatedSprite2D/downWall.get_collider()
		if up_collider is TileMapLayer && down_collider is TileMapLayer:
			print("part 1")
			var tile_pos = up_collider.local_to_map(up_collider.to_local($AnimatedSprite2D/upWall.get_collision_point()))
			var tile_data = up_collider.get_cell_tile_data(tile_pos)
			print(tile_pos)
			print("tile_data: ", tile_data)
			print("wallJumpable: ", tile_data.get_custom_data("wallJumpable") if tile_data else "NO TILE DATA")
			if tile_data and tile_data.get_custom_data("wallJumpable"):
				print("part 2")
				tile_pos = down_collider.local_to_map(up_collider.to_local($AnimatedSprite2D/upWall.get_collision_point()))
				tile_data = down_collider.get_cell_tile_data(tile_pos)
				if tile_data and tile_data.get_custom_data("wallJumpable"):
					return true
	return false
	

func _physics_process(delta):
			
	var wall = is_wall_jump_valid()
		
	# apply gravity
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if slideFrame > 0:
		slideFrame -= 1
	if direction:
		if velocity.x < 0:
			animator.scale.x = 1
		elif velocity.x >0:
			animator.scale.x = -1
		if Input.is_action_just_pressed("ui_down") && slideFrame < 1:
			velocity.x *= 1.1
			roll_vel = velocity.x
			animator.play("slide")
			slideFrame = slide_cooldown
		
		
	if is_on_floor():
		if direction && ((!animator.animation == "hard land" && !(animator.animation == "roll" || animator.animation == "slide"))|| animator.animation == "idle"):
			animator.play("walk")
		else:
			if (!animator.animation == "land" && !animator.animation == "hard land" && !(animator.animation == "roll" || animator.animation == "slide")) || !animator.is_playing():
				animator.play("idle")
			
			
		coyote = 0
		velocity.y = 0
		
	elif (coyote >= coyoteFrames):
		if velocity.y < terminal_velocity and not (wall and direction and velocity.y>0):
			velocity.y += gravity * (fall_multiplier if velocity.y > 0 else 1.0)
			if velocity.y < 0:
				animator.play("rise")
			elif velocity.y < 150:
				animator.play("0")
			else:
				animator.play("fall")
		elif wall && direction:
			if animator.animation != "wall slide":
				animator.play("wall connect")
			if (animator.frame == 3 && animator.animation == "wall connect") or animator.animation == "wall slide":
				animator.play("wall slide")
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
	var jump_condition = (is_on_floor() or (wall and direction)
	or coyote<coyoteFrames or (is_on_floor() and 
	jbuffer > 0))
	# handle jump input

	if animator.animation != "hard land":
		if (jump_condition && Input.is_action_just_pressed("ui_up")) or (is_on_floor() and jbuffer > 0 and Input.is_action_pressed("ui_up")):
			animator.play("jump")
			jbuffer = 0
			velocity.y = jump_force * -1
			if wall && direction:
				animator.play("wall jump")
				wjframe = wall_jump_frames
				velocity.x = speed *1.5  * -direction
				
	
	if Input.is_action_just_released("ui_up") && velocity.y < 0:
		velocity.y -= shorthop_factor
		if velocity.y > 0:
			animator.play("fall")
			velocity.y = 0
	
	
	
	
	if wjframe == 0:
		if ((!animator.animation == "hard land" || animator.animation == "idle") && !(animator.animation == "roll" || animator.animation == "slide")):
			velocity.x = lerp(velocity.x, speed * direction, lerp_factor)
	else:
		wjframe -= 1
	
	if animator.animation == "hard land":
		velocity.x = 0
	
	var y_vel = velocity.y
	var x_vel = velocity.x	
	var was_floored = is_on_floor()
	if (animator.animation == "slide" or animator.animation == "roll"):
		roll_or_slide = animator.animation 
	
	move_and_slide()
	
	if animator.animation == "roll" or animator.animation == "slide":
		$CollisionShape2D.disabled = true
		$RollShape.disabled = false
	else:
		if $UnRoll.is_colliding():
			animator.play(roll_or_slide)
			velocity.x = roll_vel
		else:
			$CollisionShape2D.disabled = false
			$RollShape.disabled = true
	
	
#NEW — CharacterBody2D doesn't automatically push RigidBody2D
#nodes it collides with; move_and_slide() only slides along
#them. This manually applies an impulse to any RigidBody2D
#(e.g. crates) the player just collided with, pushing it away
#from the player in the direction of contact.
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var push_dir = -collision.get_normal()
			collider.apply_central_impulse(push_dir * speed * 0.1)
	
	if !was_floored && is_on_floor():
		if Input.is_action_pressed("ui_down") && direction:
			animator.play("roll")
		else:
			animator.play("land")
	
	if !was_floored && is_on_floor() && y_vel > 1200 && (not (Input.is_action_pressed("ui_down") && direction) or y_vel > 1600):
		animator.play("hard land")
		var stretchMe = $AnimatedSprite2D.scale.y
		$AnimatedSprite2D.scale.y /= 10
		$AnimatedSprite2D.position.y += 50
		
		camera_shake(chonkiness * y_vel, 0.3)
		
		$AnimatedSprite2D.scale.y = stretchMe
		$AnimatedSprite2D.position.y -= 50
			
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
#
func _on_area_2d_body_entered(body: Node2D):
	if body is KillObject:
		get_parent()._lost(1)
		
		


func camera_shake(strength: float, duration: float = 0.3):
	$Smash.amount = round((strength*strength)/600)
	$Smash.emitting = true
	var camera = $Camera2D
	var original_pos = camera.position
	var tween = create_tween()
	var shakes = 8
	for i in shakes:
		var offset = Vector2(0, strength if i % 2 == 0 else -strength)
		tween.tween_property(camera, "position", original_pos + offset, duration / shakes)
	tween.tween_property(camera, "position", original_pos, duration / shakes)
	
