extends Node2D

@onready var is_playing: bool = false

func _ready() -> void:
	$AnimationPlayer/Cutscene1.hide()
	$AnimationPlayer/Cutscene2.hide()
	$AnimationPlayer/Cutscene3.hide()
	$"AnimationPlayer/rendered part".hide()
	$AnimationPlayer/Cutscene5.hide()
	$AnimationPlayer/Cutscene6.hide()
	$AnimationPlayer/Cutscene7.hide()
	$AnimationPlayer/Cutscene8.hide()
	$AnimationPlayer/Cutscene9.hide()
	
	play_anim()


func play_anim():
	is_playing = true
	for i in range (1,9):
		$AnimationPlayer.play(str(i))
		await $AnimationPlayer.animation_finished
	is_playing = false
