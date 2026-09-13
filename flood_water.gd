extends Node2D

@export var move_speed: float = 300.0
@export var accelerate: bool = false
@export var acceleration: float = 5.0

@onready var kill_zone: Area2D = $KillZone

var _flooding: bool = false
var end_x: float = 4539.0

func _ready() -> void:
	kill_zone.body_entered.connect(_on_kill_zone_body_entered)

func start_flooding() -> void:
	_flooding = true

func _physics_process(delta: float) -> void:
	if not _flooding:
		return
	position.x += move_speed * delta
	if accelerate:
		move_speed += acceleration * delta
	if global_position.x >= end_x:
		_flooding = false

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body is player:
		get_parent().get_parent()._lost(1)
