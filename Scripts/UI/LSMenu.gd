extends Control

@export var levels: int
@export var columns: int

@onready var button = $CenterContainer/GridContainer/LSbutton
@onready var grid = $CenterContainer/GridContainer
@onready var Back = $Back

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	grid.columns = columns
	for i in levels - 1:
		grid.add_child(button.duplicate())
	
	Back.button_up.connect(_back)
		

func _back() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Title.tscn")
