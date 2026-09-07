extends AnimatedSprite2D

#intakes a potionData preset
@export var data : potionData

@onready var area = $Area2D
func _ready() -> void:
	area.mouse_entered.connect(_clicked)
	pass # Replace with function body.


func _clicked() -> void:
	#print(data.name)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
