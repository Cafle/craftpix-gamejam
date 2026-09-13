extends StaticBody2D
class_name BreakableBlock


@export_group("Break Conditions")
@export var chonkiness_threshold: float = 0.05

@export_group("Effects")
@export var shake_strength: float = 8.0
@export var shake_duration: float = 0.2

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detector: Area2D = $BreakDetector

var _broken: bool = false


func _ready() -> void:
	var err = detector.body_entered.connect(_on_detector_body_entered)
	print(name, " connect result: ", err, " shape count: ", $BreakDetector/CollisionShape2D.shape)
	detector.body_entered.connect(_on_detector_body_entered)
	detector.body_exited.connect(_on_detector_body_exited)
	print("Break detector ready. monitoring=", detector.monitoring, " mask=", detector.collision_mask)


func _on_detector_body_entered(body: Node2D) -> void:
	print("ENTERED: ", body.name, " class=", body.get_class(), " is player? ", body is player)
	if _broken:
		return
	_check_body(body)


func _on_detector_body_exited(body: Node2D) -> void:
	print("EXITED: ", body.name)


func _physics_process(_delta: float) -> void:
	if _broken:
		return
	var bodies = detector.get_overlapping_bodies()
	if bodies.size() > 0:
		print("Overlapping bodies this frame: ", bodies)
	for body in bodies:
		_check_body(body)


func _check_body(body: Node2D) -> void:
	if _broken:
		return
	if body is player:
		var p: player = body
		print("checking player -> slamming: ", p.is_slamming(), " last_landing_speed: ", p.speed, " chonkiness: ", p.chonkiness)
		if p.is_slamming() or p.chonkiness > chonkiness_threshold:
			_break(p)


func _break(p: player) -> void:
	_broken = true

	collision_shape.set_deferred("disabled", true)
	sprite.hide()

	if p.has_method("camera_shake"):
		p.camera_shake(shake_strength, shake_duration)

	queue_free()
