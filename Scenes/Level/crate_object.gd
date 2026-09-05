extends RigidBody2D

func _ready() -> void:
	gravity_scale = 0

	linear_damp = 8

	lock_rotation = true
