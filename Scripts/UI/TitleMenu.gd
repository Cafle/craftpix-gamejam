extends Control

@onready var start = $TITLE/start
@onready var options = $TITLE/eopitois #Adam, what the actual cheese is this?
@onready var back = $Options/back
@onready var quit = $TITLE/quit

#New Save button code mimicking codepaths above
# @onready var new_save = $TITLE/new_save
# NEW. reference to the new "New Save" button


func _start_pressed() -> void:
	print("Start attempted")
	get_tree().change_scene_to_file("res://Scenes/UI/Level Select.tscn")

func _options_pressed() -> void:
	$TITLE.hide()
	$Options.show()

func _quit_pressed() -> void:
	print("Quit attempted")
	get_tree().quit()

#Needs button first before 
 #func _new_save_pressed() -> void:
	# NEW. Resets progress, then drops the player straight into
	# level 1 on a clean save.
	# print("New save started")
	# LevelSelect.resetProgress()
	# get_tree().call_deferred("change_scene_to_file", "res://Scenes/Level/1.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.button_up.connect(_start_pressed)
	options.button_up.connect(_options_pressed)
	quit.button_up.connect(_quit_pressed)	
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
