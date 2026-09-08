extends Control

@export var potions: int
@export var columns: int

@onready var potion = $CenterContainer/GridContainer/Potion
@onready var grid = $CenterContainer/GridContainer
@onready var Back = $back
@onready var desc = $desc
@onready var coins = $Coins

@export_group("Level presets")
@export var level_presets: Array[levelPotions]

@export_group("Potion Presets")
@export var jump: potionData
@export var speed: potionData



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coins.text = "Coins: " + str(LevelSelect.Coins)
	
	grid.columns = columns
	
	#spwan in potions
	for i in potions - 1:
		grid.add_child(potion.duplicate())
	
	#get current level potions preset
	var preset = level_presets[LevelSelect.current_level - 1]
	
	var count = 0
	for i in preset.potions:
		if i != null:
			grid.get_child(count).data = i
		else:
			print("null")
		
		count += 1
	
	
		
	Back.button_up.connect(_back)

func _changeDesc(text : String) -> void:
	desc.text = text

func _buy(cost : int, index : int) -> void:
	LevelSelect.Coins -= cost
	coins.text = "Coins: " + str(LevelSelect.Coins)
	grid.get_child(index).get_child(0).play("bought")
	
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _back() -> void:
	self.hide()
