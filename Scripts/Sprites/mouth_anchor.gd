extends Marker2D
const FALL          : Array[Vector2] = [Vector2(15, 22), Vector2(15, 22)]
const RISE          : Array[Vector2] = [Vector2(15, 21), Vector2(15, 21)]
const IDLE          : Array[Vector2] = [Vector2(6, 11), Vector2(6, 11), Vector2(6, 12), Vector2(6, 10), Vector2(6, 11), Vector2(6, 10)]
const WALK          : Array[Vector2] = [Vector2(10, 8), Vector2(10, 7), Vector2(10, 8), Vector2(10, 12), Vector2(10, 9), Vector2(10, 8)]
const JUMP          : Array[Vector2] = [Vector2(6, 10), Vector2(14, 15), Vector2(16, 18), Vector2(18, 27), Vector2(20, 22), Vector2(14, 4)]
const LAND          : Array[Vector2] = [Vector2(14, 44), Vector2(19, 34), Vector2(13, 28), Vector2(16, 26), Vector2(20, 18)]
const HARD_LAND     : Array[Vector2] = [Vector2(15, 22), Vector2(18, 34), Vector2(24, 31), Vector2(14, 34), Vector2(15, 34), Vector2(25, 32), Vector2(25, 32), Vector2(25, 32), Vector2(25, 32), Vector2(25, 32), Vector2(20, 18)]
const ROLL          : Array[Vector2] = [Vector2(19, 20), Vector2(8, 47), Vector2(-2, 47), Vector2(-8, 52), Vector2(-9, 55), Vector2(-14, 54), Vector2(9, 13), Vector2(5, 7), Vector2(5, 7)]
const SLIDE         : Array[Vector2] = [Vector2(-1, 13), Vector2(-26, 33), Vector2(-16, 37), Vector2(-7, 40), Vector2(-8, 38), Vector2(-8, 38), Vector2(-7, 40), Vector2(-19, 25), Vector2(-19, 11), Vector2(-1, 4), Vector2(3, 9)]
const WALL_CONNECT  : Array[Vector2] = [Vector2(4, 16), Vector2(-8, 12), Vector2(-8, 12), Vector2(-8, 12)]
const WALL_JUMP     : Array[Vector2] = [Vector2(-12, 11), Vector2(-12, 17)]
const WALL_SLIDE    : Array[Vector2] = [Vector2(-7, 12), Vector2(-7, 12)]

const ROLL_ROTATION  : Array[float] = [0, 135, 214, 231, 231, -34, 0, 0, 0]
const SLIDE_ROTATION : Array[float] = [0, -38, -48, -24, -62, -62, -24, 0, 0, 0, 0]

const MOUTH_ANCHORS := {
	"fall": FALL,
	"rise": RISE,
	"idle": IDLE,
	"walk": WALK,
	"jump": JUMP,
	"land": LAND,
	"hard land": HARD_LAND,
	"roll": ROLL,
	"slide": SLIDE,
	"wall connect": WALL_CONNECT,
	"wall jump": WALL_JUMP,
	"wall slide": WALL_SLIDE,
}

const MOUTH_ROTATIONS := {
	"roll": ROLL_ROTATION,
	"slide": SLIDE_ROTATION,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_update_mouth()
	var fire := false
	for pot in Inventory.belly:
		if pot and pot.id == 88:
			fire = true
			break
	var breathing_fire := Inventory.puking and fire
	$Flames.emitting = breathing_fire
	$Barf.emitting = Inventory.puking and not fire
	$FireBreathArea/CollisionShape2D.disabled = not breathing_fire

func _update_mouth() -> void:
	var animator = get_parent()
	var anim = animator.animation
	if MOUTH_ANCHORS.has(anim):
		var frames: Array = MOUTH_ANCHORS[anim]
		position = frames[min(animator.frame, frames.size() - 1)]
	if MOUTH_ROTATIONS.has(anim):
		var rots: Array = MOUTH_ROTATIONS[anim]
		rotation_degrees = rots[min(animator.frame, rots.size() - 1)]
	elif anim.contains("wall"):
		rotation_degrees = 180
	else:
		rotation_degrees = 0.0
