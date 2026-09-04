extends Node

@onready var SONGS: Array[AudioStreamMP3] = [
		preload("res://Assets/Music/Ale and Maidens.mp3"),
		preload("res://Assets/Music/Ale and Maidens.mp3"),
		preload("res://Assets/Music/Teseract of Infinite Knowlege.mp3")	
	]
var current_level: int = 1
var HUL: int = 1 #Highest Unlocked Level
var Max_level: int = 37 #Current Max Level on Level Select Menu

func _ready() -> void:
	# NEW FUNCTION. Runs once when this autoload initializes at
	# game start, before any level scene loads — the correct place
	# to restore saved progress.
	var data = SaveManager.load_data()
	HUL = data.get("HUL", 1)
	current_level = data.get("current_level", 1)
	# .get(key, default) falls back to 1 automatically if the key
	# is missing, which happens naturally on a fresh/empty save
	# (e.g. first launch, before anything has been saved yet).
	print("LevelManager ready — loaded HUL: ", HUL, " current_level: ", current_level)

func _changeVol(num: int) ->  void:
	# Prevent math errors with log of zero by clamping or checking
	if num <= 0.0:
		TitleMusic.volume_db = -80.0 # Muted
	else:
		TitleMusic.volume_db = linear_to_db(num)
	
	
func _playSong(num: int) -> void: 
	TitleMusic.stop()
	TitleMusic.stream = SONGS[num % SONGS.size()]
	TitleMusic.play()

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

func loadLevel(level: int) -> String:
	# UNCHANGED.
	if level > Max_level:
		return "res://Scenes/UI/Title.tscn"
	else:
		return str("res://Scenes/Level/", level, ".tscn")

func _save() -> void:
	# NEW FUNCTION. Bundles the values that need persisting into a
	# Dictionary and hands it to SaveManager. This script doesn't
	# know or care how the data gets written to disk — that
	# separation is what lets SaveManager be reused for unrelated
	# data (settings, unlocks, etc.) later without changes.
	print("Saving data: HUL=", HUL, " current_level=", current_level)
	SaveManager.save_data({"HUL": HUL, "current_level": current_level})
