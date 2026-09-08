extends Node2D

@onready var cork = $quark
@onready var bottle = $bottle
@onready var juice = $juice

@onready var juicing = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Inventory.potion_drunk.connect(_swig)
	$juice.material = $juice.material.duplicate()
	
func set_potion(pot: potionData) -> void:
	if pot:
		$juice.material.set_shader_parameter("new_color1", pot.color)
		$juice.material.set_shader_parameter("new_color2", pot.color.darkened(-1))
		show()
	else:
		hide()

func _swig() -> void:
	if Inventory.items[0] == self:
		cork.hide()
		juicing = true
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if juicing && juice.position.y < 19:
		juice.position.y += 1
