extends AnimatedSprite2D

@export var SkinTone: Color
@export var ShirtTone: Color
@export var Ruffle1Tone: Color
@export var Ruffle2Tone: Color
@export var LegTone: Color
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#SUPER IMPORTANT TO VARY THE NPC SHADERS
	material = material.duplicate()
	material.set_shader_parameter("skin", SkinTone)
	material.set_shader_parameter("dark_skin", SkinTone.darkened(0.1))
	material.set_shader_parameter("shirt", ShirtTone)
	material.set_shader_parameter("shirt_light", ShirtTone.darkened(-0.1))
	material.set_shader_parameter("shirt_dark", ShirtTone.darkened(0.1))
	material.set_shader_parameter("leg", SkinTone.darkened(0.1))
	material.set_shader_parameter("leg_dark", SkinTone.darkened(0.2))
	material.set_shader_parameter("ruffle1", Ruffle1Tone)
	material.set_shader_parameter("ruffle2", Ruffle2Tone)
	material.set_shader_parameter("ruffle_dark", Ruffle1Tone.darkened(0.1))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
