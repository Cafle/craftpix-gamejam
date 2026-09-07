extends Control

#intakes a potionData preset
@export var data : potionData

@onready var area = $Potion/Area2D

func _ready() -> void:
	area.mouse_entered.connect(_dispDesc)
	area.mouse_exited.connect(_hideDesc)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#when hovered
func _dispDesc() -> void:
	if data:
		get_tree().current_scene._changeDesc(data.desc)

#when un-hovered
func _hideDesc() -> void:
	get_tree().current_scene._changeDesc("")

#when clicked	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if data:
				print(data.name)
			else:
				print("null")
