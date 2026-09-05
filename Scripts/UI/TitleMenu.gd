extends Control

@onready var start = $TITLE/start
@onready var options = $TITLE/eopitois #Adam, what the actual cheese is this?
@onready var back = $Options/back
@onready var quit = $TITLE/quit
@onready var rebirth = $TITLE/rebirth


#sliders
@onready var music = $Options/music
@onready var sfx = $Options/sfx
# NEW. reference to the new "New Save" button


func _start_pressed() -> void:
	print("Start attempted")
	get_tree().change_scene_to_file("res://Scenes/UI/Level Select.tscn")

func _changeVol(num: float, track: int) -> void:
	#1 for music slider, 0 for sfx
	if track == 1:
		# Prevent math errors with log of zero by clamping or checking
		if num <= 0.0:
			Music.volume_db = -80.0 # Muted
		else:
			Music.volume_db = linear_to_db(num)
	else:
		# Prevent math errors with log of zero by clamping or checking
		#Sfx with capital S represents global scene of sfx audioplayer
		if num <= 0.0:
			Sfx.volume_db = -80.0 # Muted
		else:
			Sfx.volume_db = linear_to_db(num)

func _options_pressed() -> void:
	$TITLE.hide()
	$Options.show()

func _quit_pressed() -> void:
	print("Quit attempted")
	get_tree().quit()

#Needs button first before 
func _new_save_pressed() -> void:
	#NEW. Resets progress, then drops the player straight into level 1 on a clean save.
	print("New save started")
	LevelSelect.resetProgress()
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/Level/1.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.button_up.connect(_start_pressed)
	options.button_up.connect(_options_pressed)
	quit.button_up.connect(_quit_pressed)
	rebirth.button_up.connect(_new_save_pressed)
	music.value_changed.connect(_changeVol.bind(1))
	sfx.value_changed.connect(_changeVol.bind(2))
	
	sfx.value = Sfx.volume_linear
	music.value = Music.volume_linear
pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func _on_eopitois_button_up() -> void:
	
	pass # Replace with function body.



func _on_back_button_up() -> void:
	#Doing this function with a signal directly cause .connect was not working
	$Options.hide()
	$TITLE.show()
	print("Options closed")
