extends Node2D

@onready var npc = $NPC
@onready var enemies = $ENEMIES

#@export var npcPrefab : PackedScene = preload("res://NPC.tscn")
#@export var enemyPrefab : PackedScene = preload("res://Scenes/Sprites/enemy.tscn")

@export var npcPrefab = load("res://NPC.tscn")
@export var  enemyPrefab = load("res://Scenes/Sprites/enemy.tscn")

var npcSpawns = [Node2D]
var enemySpawns = [Node2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	npcSpawns.resize(npc.get_child_count())
	enemySpawns.resize(enemies.get_child_count())
	
	npcSpawns = npc.get_children()
	enemySpawns = enemies.get_children()
	
	_spawnEnemy()
	_spawnNPC()

func _spawnEnemy() -> void:
	for i in enemySpawns:
		print("EY")
		var newEnemy = enemyPrefab.duplicate()
		i.add_child(newEnemy)
		
func _spawnNPC() -> void:
	print("AY")
	for i in npcSpawns:
		var newNPC = npcPrefab.duplicate()
		i.add_child(newNPC)
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
