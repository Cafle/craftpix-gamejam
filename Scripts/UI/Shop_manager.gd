extends Control

@export var potions: int
@export var columns: int

@onready var potion = $CenterContainer/GridContainer/Potion
@onready var grid = $CenterContainer/GridContainer
@onready var Back = $back
@onready var desc = $desc
@onready var Pname = $name
@onready var coins = $Coins
@onready var play = $PLAy
@onready var tender = $Container/bartender

@export_group("Level presets")
@export var level_presets: Array[levelPotions]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Inventory._reset()
	LevelSelect.mode = "orb"
	
	play.button_up.connect(_play)
	
	coins.text = "Coins: " + str(LevelSelect.Coins)
	
	grid.columns = columns
	
	#spwan in potions
	for i in potions - 1:
		grid.add_child(potion.duplicate())
	
	#get current level potions preset
	var preset = level_presets[LevelSelect.current_level - 1]
	
	var count = 0
	if preset:
		for i in preset.potions:
			if i:
				grid.get_child(count).data = i
	
			count += 1
	
	
		
	Back.button_up.connect(_back)

func _changeDesc(text : String, name : String, cost : int) -> void:
	if text == "":
		desc.text = "Check your orb!"
		tender.frame = 0
		Pname.text = "YO!"
	else:
		desc.text = text
		Pname.text = name + " | Cost: " + str(cost)
		tender.frame = 1
	
	

func _buy(cost : int, index : int) -> void:
	LevelSelect.Coins -= cost
	coins.text = "Coins: " + str(LevelSelect.Coins)
	grid.get_child(index).get_child(0).hide()
	
func _play() -> void:
	Inventory._reversePotions()
	LevelSelect.mode = "game"
	LevelSelect._playSong(LevelSelect.current_level)
	get_tree().call_deferred("change_scene_to_file", LevelSelect.loadLevel(LevelSelect.current_level))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _back() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/UI/Level Select.tscn")
