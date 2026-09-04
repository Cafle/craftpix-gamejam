extends Control

#menus
@onready var Pause_m = $Pause
@onready var Option_m = $Options
@onready var Control_m = $Controls

#buttons
@onready var options = $Pause/eopitois
@onready var c_settings = $Options/back
@onready var restart = $Pause/Restart
@onready var controls = $Pause/Controls
@onready var c_controls = $Controls/back
@onready var resume = $Pause/Play
@onready var resume2 = $Pause/back


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	options.button_up.connect(_openOptions)
	c_settings.button_up.connect(_closeOptions)
	resume.button_up.connect(_resume)
	resume2.button_up.connect(_resume)
	controls.button_up.connect(_openControls)
	c_controls.button_up.connect(_closeControls)
	#settings.button_up.connect(_openSettings)
	#settings.button_up.connect(_openSettings)
	pass # Replace with function body.


func _openOptions() -> void:
	Pause_m.hide()
	Option_m.show()
	pass
	
func _closeOptions() -> void:
	Option_m.hide()
	Pause_m.show()
	pass
	
func _openControls() -> void:
	Pause_m.hide()
	Control_m.show()
	pass
	
func _closeControls() -> void:
	Pause_m.show()
	Control_m.hide()
	pass
	
func _resume() -> void:
	Pause_m.show()
	self.hide()
	pass
	
func _restart() -> void:
	get_tree().reload_current_scene()
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		self.show()
	pass
