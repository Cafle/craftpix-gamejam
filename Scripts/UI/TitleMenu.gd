extends Control

@onready var start = $TITLE/start
@onready var options = $TITLE/eopitois #Adam, what the actual cheese is this?
@onready var back = $Options/back
@onready var quit = $TITLE/quit

func _start_pressed() -> void:
	print("Start attempted")
	get_tree().change_scene_to_file("res://Scenes/UI/Level Select.tscn")

func _options_pressed() -> void:
	$Options.show()
	print("Options attempted")

func _back_pressed() -> void:
	$Options.hide()
	print("Options closed")

func _quit_pressed() -> void:
	print("Quit attempted")
	get_tree().quit() 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.pressed.connect(_start_pressed)
	options.pressed.connect(_options_pressed)
	quit.pressed.connect(_quit_pressed)
	back.pressed.connect(_back_pressed)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
