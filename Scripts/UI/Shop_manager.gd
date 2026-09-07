extends Control

@export var potions: int
@export var columns: int

@onready var potion = $CenterContainer/GridContainer/Potion
@onready var grid = $CenterContainer/GridContainer
@onready var Back = $back

@export var Testdata : potionData
@export var Fire : potionData
@export var water : potionData


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	grid.columns = columns
	var x = 0
	for i in potions - 1:
		print(x)
		x+=1
		grid.add_child(potion.duplicate())
	var potionslots = grid.get_children()
	
	potionslots[2].get_child(0).data = Fire
	
	potionslots[5].get_child(0).data = water
	
	for i in potionslots:
		print(i.get_child(0).data.name)
		
	Back.button_up.connect(_back)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _back() -> void:
	self.hide()
