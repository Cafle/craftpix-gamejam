extends Node

@onready var potions : Array[potionData]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	potions.resize(10)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _add(pot : potionData) -> void:
	print("addoing ", pot.name)
	for i in range (9):
		potions[9-i] = potions[8 - i]
		potions[0] = pot
	
func _drink() -> potionData:
	var temp = potions[0]
	for i in range (8):
		potions[i] = potions[i + 1]
		
	potions[9] = null
	return temp
