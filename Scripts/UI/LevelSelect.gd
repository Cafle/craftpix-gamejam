extends Node

@onready var mode = "orb"

@onready var SONGS: Array[AudioStreamMP3] = [
		load("res://Assets/Music/Ale and Maidens.mp3"),
		load("res://Assets/Music/First Sip.mp3"),
		load("res://Assets/Music/Teseract of Infinite Knowlege.mp3")	
	]

var  wedding = load("res://Scenes/cutscenes/Wedding.tscn")
var intro = load("res://Scenes/cutscenes/cutscene_1.tscn")
var title =  load("res://Scenes/UI/Title.tscn")
var lvl_sel =  load("res://Scenes/UI/Level Select.tscn")
var shop = load("res://Scenes/UI/Shop.tscn")

@onready var preLevel:  = {
		1: load("res://Scenes/Level/1.tscn"),
		2: load("res://Scenes/Level/2.tscn"),
		3: load("res://Scenes/Level/3.tscn"),
		4: load("res://Scenes/Level/4.tscn"),
		5: load("res://Scenes/Level/5.tscn"),
		#6: load("res://Scenes/Level/6.tscn"),
		7: load("res://Scenes/Level/7.tscn"),
		#8: load("res://Scenes/Level/8.tscn"),
		#9: load("res://Scenes/Level/9.tscn"),
		#10: load("res://Scenes/Level/10.tscn"),
		
			
	}
	
var current_level: int = 1
var HUL: int = 1 #Highest Unlocked Level
var Max_level: int = 1 #Current Max Level on Level Select Menu
var Coins : int = 0
var seenIntroCutscene: bool = false
var seenWeddingCutscene: bool = false

func _ready() -> void:
	var data = SaveManager.load_data()
	HUL = data.get("HUL", 1)
	current_level = data.get("current_level", 1)
	Coins = data.get("coin", 1)
	seenIntroCutscene = data.get("seenIntroCutscene", true) 
	seenWeddingCutscene = data.get("seenWeddingCutscene", true) 
	print("LevelManager ready — loaded HUL: ", HUL, " current_level: ", current_level, " seenIntroCutscene: ", seenIntroCutscene)
	

	
	
func _playSong(num: int) -> void: 
	Music.stop()
	Music.stream = SONGS[num % SONGS.size()]
	Music.play()


func unlockLevel(level: int) -> void:
	# Core if-check is UNCHANGED from the original.
	print("unlockLevel called with: ", level, " current HUL: ", HUL) # debug trace
	if level > HUL:
		HUL = level
		# NEW: trigger a save the moment HUL actually increases,
		# instead of only saving on quit — safer if the game
		# crashes or gets force-closed.
		print("HUL updated to: ", HUL, " — saving now")
		_save()
	else:
		print("Level ", level, " did not exceed current HUL, not saving")

func loadLevel(level: int) -> PackedScene:
	if get_tree().current_scene == shop:
		return preLevel[level]
	
	if level > Max_level:
		return title
	if level == 1 and not seenIntroCutscene:
		seenIntroCutscene = true
		return intro
	if level == 2 and not seenWeddingCutscene:
		seenWeddingCutscene = true
		return wedding
	
	return shop

func _save() -> void:
	print("Saving data: HUL=", HUL, " current_level=", current_level, " seenIntroCutscene=", seenIntroCutscene, " seenWeddingCutscene=", seenWeddingCutscene)
	SaveManager.save_data({
		"HUL": HUL,
		"current_level": current_level,
		"coin": Coins,
		"seenIntroCutscene": seenIntroCutscene,
		"seenWeddingCutscene": seenWeddingCutscene
	})
	
func resetProgress() -> void:
	#NEW FUNCTION. Reset player progress
	# Resets progress in memory, then overwrites the save file
	# on disk with those same default values.
	HUL = 1
	current_level = 1
	seenIntroCutscene = false
	seenWeddingCutscene = false
	print("reset stuff")
	_save()
	# Reuses the existing _save() function — no need to write new
	# file-handling code, since save_data() already overwrites
	# the file rather than appending to it.
	print("Progress reset — HUL: ", HUL, " current_level: ", current_level)
