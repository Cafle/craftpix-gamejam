extends Control

@export var potions: int
@export var columns: int

@onready var potion = $VBoxContainer/CenterContainer/GridContainer/Potion
@onready var grid = $VBoxContainer/CenterContainer/GridContainer
@onready var Back = $back

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	grid.columns = columns
	var x = 0
	for i in potions:
		print(x)
		x+=1
		grid.add_child(potion.duplicate())
	print
	Back.button_up.connect(_back)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _back() -> void:
	self.hide()
