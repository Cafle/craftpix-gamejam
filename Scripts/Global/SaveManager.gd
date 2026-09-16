extends Node
# Generic autoload for reading/writing save data to disk.
# Knows nothing about levels, HUL, etc. — just saves/loads whatever
# Dictionary it's given. Reusable later for settings, unlocks, etc.
# Must be listed ABOVE LevelSelect in Project Settings > Autoload,
# since LevelSelect._ready() calls SaveManager.load_data() on startup.

const SAVE_PATH = "user://save_data.json"
# "user://" points to Godot's OS-managed, writable, persistent data
# folder (different real folder per platform), unlike "res://" which
# is the game's bundled, read-only project files.

func save_data(data: Dictionary) -> void:
	print("SaveManager writing to: ", SAVE_PATH) # debug trace

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	# WRITE mode always starts from a blank file — old contents
	# are wiped the moment it's opened this way.

	if file == null:
		# open() returns null instead of throwing if it fails
		# (bad path, permissions, etc). Without this check, the
		# next line would crash by calling a method on null.
		print("ERROR opening file for write: ", FileAccess.get_open_error())
		return

	file.store_string(JSON.stringify(data))
	# Converts the Dictionary into a JSON string, e.g.
	# {"HUL": 5} -> '{"HUL":5}', and writes that text to the file.

	file.close()
	# Flushes the write to disk. Godot buffers writes internally,
	# so skipping close() risks the data never actually being saved.
	print("Save complete")


func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		# Guards the first-ever launch, when no save exists yet.
		# Return {} (not null) so callers can safely call
		# .get(key, default) on the result without null-checking.
		print("No save file found at: ", SAVE_PATH)
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		# Same defensive check as save_data() — log and bail
		# instead of crashing if the open fails.
		print("ERROR opening file for read: ", FileAccess.get_open_error())
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	# get_as_text() reads the whole file as one raw string.
	# parse_string() turns that string back into a value.
	# No type hint (var, not var :=) because this can return
	# null if the file's JSON is corrupted/invalid.

	file.close()

	if typeof(parsed) == TYPE_DICTIONARY:
		# Confirm parsing actually produced a Dictionary before
		# returning it — protects callers from a null crash if
		# the save file got corrupted.
		print("Loaded save data: ", parsed)
		return parsed

	print("Save file exists but failed to parse as Dictionary")
	return {}
	# Keeps the function's contract solid: always returns a
	# Dictionary, valid or empty, never null.
