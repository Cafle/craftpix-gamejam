extends Node

@onready var SONGS: Array[AudioStreamMP3] = [
		preload("res://Assets/Music/Menacing Title screen.mp3"),
		preload("res://Assets/Music/Nebulas and Nocturnes.mp3"),
		preload("res://Assets/Music/Teseract of Infinite Knowlege.mp3")	
	]



var current_level: int = 1
var HUL: int = 1 #Highest Unlocked Level
var Max_level: int = 37 #Placeholder value

func _playSong(num: int) -> void:
	TitleMusic.stop()
	TitleMusic.stream = SONGS[num]
	TitleMusic.play()

func unlockLevel(level: int) -> void:
	if level>HUL:
		HUL = level

func loadLevel(level: int) -> String:
	
	if level > Max_level:
		return "res://Scenes/UI/Title.tscn"
	else:
		return str("res://Scenes/Level/", level,".tscn")
