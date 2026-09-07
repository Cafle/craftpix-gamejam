extends Control

@export var potions: int
@export var columns: int

@onready var potion = $Potion
@onready var grid = $VBoxContainer/GridContainer
@onready var Back = $back

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	grid.columns = columns
	for i in potions:
		grid.add_child(potion.duplicate())
	
	Back.button_up.connect(_back)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _back() -> void:
	self.hide()
