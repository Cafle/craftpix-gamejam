extends Node

@onready var potions : Array[potionData] 
@onready var ogpotions : Array[potionData] 
@onready var frame_delay = 87 # A decent time loaded into a level
@onready var frame = 10
@onready var amounts: Array[float] = [0,0,0,0,0,0,0,0,0,0]
@onready var belly: Array[potionData] = []
@onready var puking = false
@onready var intoxication = 0

signal potion_trigger(pot: potionData)
signal potion_drunk()
signal barf(amount: float)

var items : Array[Node2D] 
var held = false
var photbar : CanvasLayer
var vial : Node2D

func _sum(arr: Array) -> float:
	var sum = 0
	for i in arr:
		sum += i
	return sum
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items.resize(10)		
	potions.resize(10)
	ogpotions.resize(10)
	belly.resize(10)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	var currentScene = get_tree().current_scene
	
	if currentScene is not Level:
		frame = 0
		return
	
	if frame < frame_delay:
		frame += 1
	
	if frame == frame_delay and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not held:
		_drink()
		held = true
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		held = false
		
func _activateHotbar(root : CanvasLayer) -> void:
	potions = ogpotions.duplicate()
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
	vial.queue_free()
	_refresh_vials()
	
func _add(pot : potionData) -> void:
	for i in range (9):
		ogpotions[9-i] = ogpotions[8 - i]
	
	ogpotions[0] = pot
	
	
	
func _reset() -> void:
	LevelSelect.Coins = 10
	ogpotions = [null, null, null, null,null,null,null,null,null,null]
	potions = [null, null, null, null,null,null,null,null,null,null]
	items = [null, null, null, null,null,null,null,null,null,null]
	
func _drink() -> void:
	if potions[0]:
		if intoxication + potions[0].proof <= 10:
			if potions[0] is potionData:
				intoxication += potions[0].proof
				potion_drunk.emit()
				potion_trigger.emit(potions[0])
				var bot = items[0]
				var temp = potions[0]
				for i in range (9):
					potions[i] = potions[i + 1]
					items[i] = items[i + 1]
					
				potions[9] = null
		_refresh_vials()

func _refresh_vials() -> void:
	for i in range(items.size()):
		if items[i]:
			items[i].set_potion(potions[i])
			
func _barf(left: float):
	barf.emit(left)
	
