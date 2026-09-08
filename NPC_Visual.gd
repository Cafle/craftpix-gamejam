extends AnimatedSprite2D

@export var SkinTone: Color
@export var ShirtTone: Color
@export var Ruffle1Tone: Color
@export var Ruffle2Tone: Color
@export var LegTone: Color
@export var randomize_on_ready: bool = true
@export var face_shader: Shader

@export_group("Gender Variants")
@export var male_sprite_frames: SpriteFrames
@export var female_sprite_frames: SpriteFrames
@export_range(0.0, 1.0) var female_chance: float = 0.5

@export_group("Accessory Sheets - Male")
@export var hat_sheet: Texture2D
@export var hat_count: int = 11
@export var male_hair_sheet: Texture2D
@export var male_hair_count: int = 11
@export var male_face_sheet: Texture2D
@export var male_face_count: int = 11

@export_group("Accessory Sheets - Female")
@export var female_hair_sheet: Texture2D
@export var female_hair_count: int = 11
@export var female_face_sheet: Texture2D
@export var female_face_count: int = 11

@export_group("Accessory Odds")
@export_range(0.0, 1.0) var hat_chance: float = 0.333   # male only
@export_range(0.0, 1.0) var hair_chance: float = 0.5     # applies to both genders
@export_range(0.0, 1.0) var face_chance: float = 1.0

@onready var hat_anchor: Marker2D = $HatAnchor
@onready var hat_sprite: Sprite2D = $HatAnchor/HatSprite
@onready var hair_anchor: Marker2D = $HairAnchor
@onready var hair_sprite: Sprite2D = $HairAnchor/HairSprite
@onready var face_anchor: Marker2D = $FaceAnchor
@onready var face_sprite: Sprite2D = $FaceAnchor/FaceSprite

var is_female: bool = false
var hair_sheet: Texture2D
var hair_count: int
var face_sheet: Texture2D
var face_count: int

# Head position per animation/frame, relative to the AnimatedSprite2D origin.
# Any animation not listed falls back to "idle" frame 0.
var head_anchor_offsets: Dictionary = {
	"idle": [
		Vector2(0, -1),  # frame 0
		Vector2(0, -1),  # frame 1
		Vector2(0, -2), # frame 2
		Vector2(0, -2), # frame 3
		Vector2(0, -2),  # frame 4
		Vector2(0, -1),  # frame 5
	],
}

func _ready() -> void:
	_pick_gender()
	if randomize_on_ready:
		randomize_appearance()
	apply_shader_colors()
	_setup_face_material()
	_randomize_accessories()

	animation_changed.connect(_update_anchor)
	frame_changed.connect(_update_anchor)

	play("idle")
	_update_anchor()

func _pick_gender() -> void:
	is_female = randf() < female_chance
	sprite_frames = female_sprite_frames if is_female else male_sprite_frames
	hair_sheet = female_hair_sheet if is_female else male_hair_sheet
	hair_count = female_hair_count if is_female else male_hair_count
	face_sheet = female_face_sheet if is_female else male_face_sheet
	face_count = female_face_count if is_female else male_face_count

func randomize_appearance() -> void:
	SkinTone = Color.from_hsv(randf_range(0.02, 0.09), randf_range(0.35, 0.65), randf_range(0.55, 0.95))

	var shirt_hue := randf()
	var shirt_sat := randf_range(0.4, 0.8)
	ShirtTone = Color.from_hsv(shirt_hue, shirt_sat, randf_range(0.4, 0.9))

	Ruffle1Tone = Color.from_hsv(shirt_hue, clampf(shirt_sat + randf_range(-0.15, 0.15), 0.2, 1.0), randf_range(0.5, 1.0))
	Ruffle2Tone = Color.from_hsv(shirt_hue, clampf(shirt_sat + randf_range(-0.15, 0.15), 0.2, 1.0), randf_range(0.3, 0.7))

func apply_shader_colors() -> void:
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
	var face_material := material.duplicate()
	face_material.set_shader_parameter("skin", SkinTone.darkened(0.15))
	face_material.set_shader_parameter("tolerance", 0.08)  # back to default, precise key handles the nose now
	face_sprite.material = face_material
	print("face material assigned: ", face_sprite.material, " skin param: ", face_material.get_shader_parameter("skin"))

func _setup_face_material() -> void:
	var face_material := ShaderMaterial.new()
	face_material.shader = face_shader
	face_material.set_shader_parameter("skin", SkinTone.darkened(0.15))
	face_sprite.material = face_material

func _randomize_accessories() -> void:
	_apply_head_accessory()
	_apply_random_slice(face_sprite, face_sheet, face_count, face_chance)

func _apply_head_accessory() -> void:
	if is_female:
		# Women: hair or bald only, never a hat
		hat_sprite.visible = false
		_apply_random_slice(hair_sprite, hair_sheet, hair_count, hair_chance)
	else:
		# Men: hat, hair, or bald - three-way split
		var roll := randf()
		if roll < hat_chance:
			_apply_random_slice(hat_sprite, hat_sheet, hat_count, 1.0)
			hair_sprite.visible = false
		elif roll < hat_chance + hair_chance:
			_apply_random_slice(hair_sprite, hair_sheet, hair_count, 1.0)
			hat_sprite.visible = false
		else:
			hat_sprite.visible = false
			hair_sprite.visible = false

func _apply_random_slice(sprite: Sprite2D, sheet: Texture2D, count: int, chance: float) -> void:
	if sheet and randf() < chance:
		var slices := slice_horizontal_strip(sheet, count)
		sprite.texture = slices[randi() % slices.size()]
		sprite.visible = true
	else:
		sprite.visible = false

func _update_anchor() -> void:
	var offsets: Array = head_anchor_offsets.get(animation, head_anchor_offsets["idle"])
	var idx: int = clampi(frame, 0, offsets.size() - 1)
	var head_offset: Vector2 = offsets[idx]
	hat_anchor.position = head_offset
	hair_anchor.position = head_offset
	face_anchor.position = head_offset

static func slice_horizontal_strip(texture: Texture2D, count: int) -> Array[Texture2D]:
	var slices: Array[Texture2D] = []
	var cell_width := texture.get_width() / float(count)
	var height := texture.get_height()
	for i in count:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * cell_width, 0, cell_width, height)
		slices.append(atlas)
	return slices
