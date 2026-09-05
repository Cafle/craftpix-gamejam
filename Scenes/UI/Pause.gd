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

#sliders
@onready var music = $Options/music
@onready var sfx = $Options/sfx

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#connect buttons to functions
	
	options.button_up.connect(_openOptions)
	c_settings.button_up.connect(_closeOptions)
	resume.button_up.connect(_resume)
	resume2.button_up.connect(_resume)
	controls.button_up.connect(_openControls)
	c_controls.button_up.connect(_closeControls)
	restart.button_up.connect(_restart)
	
	music.value_changed.connect(_changeVol.bind(1))
	sfx.value_changed.connect(_changeVol.bind(2))
	
	#set sliders to correct values
	sfx.value = Sfx.volume_linear
	music.value = Music.volume_linear


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
	
func _changeVol(num: float, track: int) -> void:
	#1 for music slider, 0 for sfx
	print("num: ", num, " track: ", track)
	if track == 1:
		print("music val is " , num)
		# Prevent math errors with log of zero by clamping or checking
		if num <= 0.0:
			Music.volume_db = -80.0 # Muted
		else:
			Music.volume_db = linear_to_db(num)
	else:
		print("sfx val is " , num)
		# Prevent math errors with log of zero by clamping or checking
		#Sfx with capital S represents global scene of sfx audioplayer
		if num <= 0.0:
			Sfx.volume_db = -80.0 # Muted
		else:
			Sfx.volume_db = linear_to_db(num)

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		self.show()
	pass
