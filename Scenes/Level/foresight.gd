extends CharacterBody2D


const SPEED = 500.0
func _ready() -> void:
	$CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var up_direction = Input.get_axis("up", "down")
	if up_direction:
		velocity.y = up_direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
