extends Control

#intakes a potionData preset
@export var data : potionData:
	set(value):
		data = value
		_apply_data()
@export var potion_card_scene: PackedScene
@onready var area = $Potion/Area2D

var bought = false

func _ready() -> void:
	area.mouse_entered.connect(_dispDesc)
	area.mouse_exited.connect(_hideDesc)
	_apply_data()
	pass # Replace with function body.

func _apply_data() -> void:
	if data and is_node_ready():
		$Potion.modulate = data.color
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
			if data && !bought:
				if data.cost > LevelSelect.Coins:
					print("BOEKW")
				else:
					Inventory._add(data)
					get_tree().current_scene._buy(data.cost, get_index())
					bought = true
			else:
				print("null")
