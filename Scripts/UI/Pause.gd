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
@onready var quit = $Pause/quit
@onready var resume = $Pause/back
@onready var shop = $Pause/shop

#audio busses
@onready var music_idx = AudioServer.get_bus_index("Music")
@onready var sex = AudioServer.get_bus_index("SFX")

#sliders
@onready var music = $Options/music
@onready var sfx = $Options/sfx

#screen shake toggle
@onready var SS = $Options/C_Shake/C_shake

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#connect buttons to functions
	
	options.button_up.connect(_openOptions)
	c_settings.button_up.connect(_closeOptions)
	quit.button_up.connect(_quit)
	resume.button_up.connect(_resume)
	controls.button_up.connect(_openControls)
	c_controls.button_up.connect(_closeControls)
	restart.button_up.connect(_restart)
	shop.button_up.connect(_shop)
	
	music.value_changed.connect(_changeVol.bind(1))
	sfx.value_changed.connect(_changeVol.bind(2))
	
	SS.toggled.connect(_changeSS)
	
	#set sliders to correct values
	
	sfx.value = db_to_linear(AudioServer.get_bus_volume_db(sex))
	music.value = db_to_linear(AudioServer.get_bus_volume_db(music_idx))
	
	#set screen shake to correct value
	
	SS.button_pressed = Inventory.screenShake
	

func _shop() -> void:
	LevelSelect.Coins = 10
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/UI/shop.tscn")

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
	
func _closeControls() -> void:
	Pause_m.show()
	Control_m.hide()
	
func _resume() -> void:
	Pause_m.show()
	self.hide()
	get_tree().paused = false
	
func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	pass
	
func _quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/Level Select.tscn")
	pass
	
func _changeVol(num: float, track: int) -> void:
	#1 for music slider, 0 for sfx
	if track == 1:
		# Prevent math errors with log of zero by clamping or checking
		if num <= 0.0:
			AudioServer.set_bus_volume_db(music_idx, -10.0)
		else:
			AudioServer.set_bus_volume_db(music_idx, linear_to_db(num))
	else:
		# Prevent math errors with log of zero by clamping or checking
		#Sfx with capital S represents global scene of sfx audioplayer
		if num <= 0.0:
			AudioServer.set_bus_volume_db(sex, -10.0)
		else:
			AudioServer.set_bus_volume_db(sex, linear_to_db(num))

func _changeSS(toggle : bool) -> void:
	if toggle:
		Inventory.screenShake = true
	else:
		Inventory.screenShake = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		self.show()
	pass
