extends CanvasLayer

@onready var capacity = LevelSelect.current_level + 3
@onready var belly = 0
@onready var glorp_progress: float = 1.0 #the percentage left of the top potion on the stack
@onready var current_tummy: Array[Node] = []
var amount_left: Array[float] = []
signal barf()

func _sum(arr: Array[float]) -> float:
	var sum = 0.0
	for i in arr:
		sum += i
	print (sum)
	return sum

func _ready() -> void:
	Inventory.potion_trigger.connect(_yummy_in_my_tummy)
	current_tummy.resize(10)
	amount_left.resize(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Inventory.puking = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and belly > 0:
		_barf(delta)

func _yummy_in_my_tummy(pot: potionData) -> void:
	if belly >= capacity:
		return
	if belly > 0:
		amount_left[belly - 1] = glorp_progress   # freeze the partial below
	var clone = $joose.duplicate()
	add_child(clone)
	clone.show()
	amount_left[belly] = 1.0
	clone.position.y -= _sum(amount_left) * 100 -100
	current_tummy[belly] = clone
	Inventory.belly[belly] = pot
	Inventory.amounts[belly] = 1
	clone.material = $joose.material.duplicate()
	clone.material.set_shader_parameter("new_color1", pot.color)
	clone.material.set_shader_parameter("new_color2", pot.color.darkened(-1))
	belly += 1
	glorp_progress = 1.0                          # new potion is full
	
func _barf(delta: float):
	Inventory.puking = true
	barf.emit()
	if glorp_progress > 0:
		glorp_progress -= delta/2
		print(glorp_progress)
		if current_tummy[belly-1]:
			current_tummy[belly-1].scale.y = glorp_progress
			Inventory._barf(glorp_progress)
			amount_left[belly] = glorp_progress
	if glorp_progress <= 0.0:
		current_tummy[belly - 1].queue_free()
		current_tummy[belly - 1] = null
		belly -= 1
		Inventory.belly[belly] = null
		Inventory.amounts = amount_left
		glorp_progress = amount_left[belly - 1] if belly > 0 else 1.0
		
	
