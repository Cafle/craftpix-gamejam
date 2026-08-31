extends Control

@export var levels: int
@export var columns: int

@onready var button = $CenterContainer/GridContainer/LSbutton
@onready var grid = $CenterContainer/GridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid.columns = columns
	for i in levels - 1:
		grid.add_child(button.duplicate())
