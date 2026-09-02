extends Node

var current_level: int = 1
var HUL: int = 1 #Highest Unlocked Level
var Max_level: int = 37 #Placeholder value

func unlockLevel(level: int) -> void:
	if level>HUL:
		HUL = level

func loadLevel(level: int) -> String:
	
	if level > Max_level:
		return "res://Scenes/UI/Title.tscn"
	else:
		return str("res://Scenes/Level/", level,".tscn")
