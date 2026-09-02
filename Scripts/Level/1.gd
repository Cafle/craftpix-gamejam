extends Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tilemap = $TileMapBase
	var killObject = $KillObjects/KillObject
	var winObject = $WinObject
	
	var Scan = _scanLevel(tilemap, 2, "kill", true)
	_replace_tiles(tilemap, 2, killObject, Scan)
	
	Scan = _scanLevel(tilemap, 2, "win", true)
	_replace_tiles(tilemap, 2, winObject, Scan)
	
	$WinObject/Sprite2D/Area2D.body_entered.connect(_win)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _win() -> void:
	# THIS FUNCTION WAS THE ROOT CAUSE of progress not saving.
	# unlockLevel() was never being called from anywhere in the
	# game, so HUL never changed and _save() never triggered —
	# regardless of whether SaveManager itself worked correctly.

	var next_level = LevelSelect.current_level + 1
	# NEW: compute this once instead of repeating
	# "LevelSelect.current_level + 1" in three places below —
	# also avoids current_level drifting mid-function if it were
	# updated before all three uses.

	LevelSelect.unlockLevel(next_level)
	# NEW — this is the actual fix. This line was completely
	# missing before. Bumps HUL if next_level is higher, and
	# triggers the save via LevelSelect._save().

	LevelSelect.current_level = next_level
	# NEW. Previously current_level was set once at declaration
	# (= 1) and never updated again anywhere, so it never reflected
	# real progress past the very first level.

	LevelSelect._playSong(next_level)
	# UNCHANGED in behavior, now just using the next_level variable.


	get_tree().call_deferred("change_scene_to_file", LevelSelect.loadLevel(next_level))
	# UNCHANGED in behavior, now just using the next_level variable.

func _lost(ani : int) -> void :
	print(ani)
	get_tree().reload_current_scene()
	
	
func _scanLevel(tileMap: TileMapLayer, source_id: int, property: String, value) -> Array:
	
	var cells = []
	var tileset = tileMap.tile_set
	var source = tileset.get_source(source_id)
	
	for i in source.get_tiles_count():
		var atlas_coords = source.get_tile_id(i)
		var tile_data = source.get_tile_data(atlas_coords, 0)
		if tile_data and tile_data.get_custom_data(property) == value:
			# add all world cells using these coords to kill_cells
			cells.append_array(tileMap.get_used_cells_by_id(source_id, atlas_coords))
	#var tile_data = source.get_tile_data(atlas_coords, 0)
	return cells

func _replace_tiles(tileMap: TileMapLayer, source_id: int, replacementNode, coords: Array) -> void:
	for i in coords:
		tileMap.erase_cell(i)
		print("attempting duplicate")
		var obj = replacementNode.duplicate()
		replacementNode.add_sibling(obj)
		obj.position = tileMap.to_global(tileMap.map_to_local(i))
		obj.show()
	replacementNode.queue_free()
