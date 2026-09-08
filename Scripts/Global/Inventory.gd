extends Node

@onready var potions : Array[potionData] 
@onready var ogpotions : Array[potionData] 

signal potion_drunk()

var items : Array[Node2D] 
var held = false
var photbar : CanvasLayer
var vial : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items.resize(10)		
	potions.resize(10)
	ogpotions.resize(10)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_F) and Input.is_key_label_pressed(KEY_F) and not held:
		_drink()
		held = true
	if not Input.is_key_pressed(KEY_F) and not Input.is_key_label_pressed(KEY_F):
		held = false
		
func _activateHotbar(root : CanvasLayer) -> void:
	potions = ogpotions.duplicate()
	print(ogpotions)
	photbar = root
	vial = root.get_child(1)
	items[0] = vial
	var count = 0
	for i in range (0,9):
		if potions[i] == null:
			break
		count+=1
		
		
	for i in range (0, count):
		items[i] = vial.duplicate()
		root.add_child(items[i])
		items[i].position.x += 64 * (i)
		
		#64 pixels apart
	vial.free()
	
func _add(pot : potionData) -> void:
	print("begore ",potions)
	print("addoing ", pot.name)
	for i in range (9):
		ogpotions[9-i] = ogpotions[8 - i]
	
	ogpotions[0] = pot
	print("afgter ",potions)
	
func _drink() -> void:
	if potions[0] is potionData:
		potion_drunk.emit()
		var bot = items[0]
		var temp = potions[0]
		for i in range (9):
			potions[i] = potions[i + 1]
			items[i] = items[i + 1]
			
		potions[9] = null
	
