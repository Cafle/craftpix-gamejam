extends CanvasLayer

@onready var joose = $PotionMask/joose

@onready var T = $Overbar/Tipsy
@onready var S = $Overbar/Sloshed
@onready var W = $Overbar/Wasted

@export var Tipsy := 1
@export var Sloshed := 2
@export var Wasted := 3

@export var capacity := 10
@export var hide_delay := 2.0
@export var barf_rate := 0.5        # fill drained per second

var belly := 0
var glorp_progress := 1.0           # fill left on the top potion
var current_tummy: Array[Node] = []
var amount_left: Array[float] = []

var showing := false
var _hide_at := 0.0

signal barf()


func _ready() -> void:
	current_tummy.resize(10)
	amount_left.resize(10)
	Inventory.amounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

	T.position.y -= 64 * Tipsy
	S.position.y -= 64 * Sloshed
	W.position.y -= 64 * Wasted
	if T.position.y == 315: T.queue_free()
	if S.position.y == 315: S.queue_free()
	if W.position.y == 315: W.queue_free()

	hide()
	$AnimationPlayer.play_backwards("ShowBar")
	await $AnimationPlayer.animation_finished
	show()

	Inventory.potion_trigger.connect(_yummy_in_my_tummy)


func _process(delta: float) -> void:
	var total_juices = _sum(Inventory.amounts)
	if total_juices < Tipsy:
		Inventory.intoxication = 0
	if total_juices > Tipsy:
		Inventory.intoxication = 1
	if total_juices > Sloshed:
		Inventory.intoxication = 2
	if total_juices > Wasted:
		Inventory.intoxication = 3
	
	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and belly > 0:
		_barf(delta)
	else:
		Inventory.puking = false

	if showing and _now() >= _hide_at:
		showing = false
		$AnimationPlayer.play_backwards("ShowBar")


# --- visibility ------------------------------------------------------

func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


func _poke() -> void:
	_hide_at = _now() + hide_delay
	if not showing:
		showing = true
		$AnimationPlayer.play("ShowBar")


# --- stack -----------------------------------------------------------

func _sum(arr: Array) -> float:
	var total := 0.0
	for v in arr:
		total += v
	return total


func _sync_inventory() -> void:
	for i in amount_left.size():
		Inventory.amounts[i] = amount_left[i]


func _yummy_in_my_tummy(pot: potionData) -> void:
	if _sum(amount_left) >= capacity:
		return

	if belly > 0:
		amount_left[belly - 1] = glorp_progress      # freeze the partial below

	amount_left[belly] = 1.0

	var clone = joose.duplicate()
	$PotionMask.add_child(clone)
	clone.show()
	clone.position.y -= _sum(amount_left) * 64 - 64
	clone.material = joose.material.duplicate()
	clone.material.set_shader_parameter("new_color1", pot.color)
	clone.material.set_shader_parameter("new_color2", pot.color.darkened(-1))

	current_tummy[belly] = clone
	Inventory.belly[belly] = pot
	belly += 1
	glorp_progress = 1.0

	_sync_inventory()
	_poke()


func _barf(delta: float) -> void:
	if belly <= 0:
		return

	_poke()
	Inventory.puking = true
	barf.emit()

	glorp_progress = maxf(glorp_progress - delta * barf_rate, 0.0)
	amount_left[belly - 1] = glorp_progress

	var top = current_tummy[belly - 1]
	if top:
		top.scale.y = glorp_progress
	Inventory._barf(glorp_progress)

	if glorp_progress <= 0.0:
		if top:
			top.queue_free()
		current_tummy[belly - 1] = null
		amount_left[belly - 1] = 0.0
		belly -= 1
		Inventory.belly[belly] = null
		glorp_progress = amount_left[belly - 1] if belly > 0 else 1.0

	_sync_inventory()
