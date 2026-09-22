extends Control

#intakes a potionData preset
@export var data : potionData:
	set(value):
		data = value
@export var potion_card_scene: PackedScene
@onready var area = $Potion/Area2D

var bought = false

func _ready() -> void:
	$Potion.material = $Potion.material.duplicate()
	area.mouse_entered.connect(_dispDesc)
	area.mouse_exited.connect(_hideDesc)
	
	
func set_potion(pot: potionData) -> void:
	if pot:
		if $Potion.material is not  PlaceholderMaterial:
			$Potion.material.set_shader_parameter("new_color1", pot.color)
			$Potion.material.set_shader_parameter("new_color2", pot.color.darkened(-1))
			show()
	else:
		hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if data:
		show()
		set_potion(data)
	else:
		hide()


#when hovered
func _dispDesc() -> void:
	if data:
		get_tree().current_scene._changeDesc(data.desc, data.name, data.cost)

#when un-hovered
func _hideDesc() -> void:
	get_tree().current_scene._changeDesc("", "", 0)

#when clicked	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if data && !bought:
				if data.cost > LevelSelect.Coins:
					var mat = $Potion.material.duplicate()
					$Potion.material = $Potion/Area2D.material.create_placeholder()
					await get_tree().create_timer(0.1).timeout
					$Potion.material = mat
				else:
					Inventory._add(data)
					get_tree().current_scene._buy(data.cost, get_index())
					bought = true
			else:
				print("null")
