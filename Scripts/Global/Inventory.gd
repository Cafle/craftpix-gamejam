extends Node

@onready var potions : Array[potionData] 

signal potion_drunk()

var items : Array[Node2D] 
var held = false
var photbar : CanvasLayer
var vial : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items.resize(10)		
	potions.resize(10)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_F) and Input.is_key_label_pressed(KEY_F) and not held:
		_drink()
		held = true
	if not Input.is_key_pressed(KEY_F) and not Input.is_key_label_pressed(KEY_F):
		held = false
		
func _activateHotbar(root : CanvasLayer) -> void:
	photbar = root
	vial = root.get_child(1)
	items[0] = vial
	for i in range (0, 9):
		print("uo")
		items[i + 1] = vial.duplicate()
		root.add_child(items[i + 1])
		items[i + 1].position.x += 64 * (i + 1)
		
		#64 pixels apart

func _add(pot : potionData) -> void:
	print("addoing ", pot.name)
	for i in range (9):
		potions[9-i] = potions[8 - i]
		potions[0] = pot
	
func _drink() -> void:
	potion_drunk.emit()
	var bot = items[0]
	var temp = potions[0]
	for i in range (9):
		potions[i] = potions[i + 1]
		items[i] = items[i + 1]
		
	potions[9] = null
	
