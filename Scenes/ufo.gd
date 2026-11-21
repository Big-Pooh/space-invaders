extends Area2D

class_name Ufo

const POINT_VALUES = [50, 100, 150, 300]

@export var speed = 200
# -1 = flies right-to-left, 1 = left-to-right. Set by the spawner.
var direction = -1
var is_dead = false

@onready var sprite_2d = $Sprite2D
@onready var shooting_point = $ShootingPoint
@onready var collision_shape = $CollisionShape2D

var explosion_texture = preload("res://Assets/Ufo/Ufo-explosion.png")
var font = preload("res://Assets/font/andina.ttf")
var engine_sound: AudioStreamPlayer


func _ready():
	add_to_group("ufo")
	engine_sound = AudioStreamPlayer.new()
	engine_sound.stream = preload("res://Assets/Sounds/ufo_loop.wav")
	engine_sound.volume_db = -10.0
	engine_sound.finished.connect(engine_sound.play)
	add_child(engine_sound)
	engine_sound.play()


func _process(delta):
	position.x += delta * speed * direction


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


# Called by the player's laser.
func hit():
	if is_dead:
		return
	is_dead = true
	collision_shape.set_deferred("disabled", true)
	shooting_point.queue_free()
	speed = 0
	engine_sound.stop()
	sprite_2d.texture = explosion_texture
	Sfx.play("ufo_killed", -4.0)

	var points = POINT_VALUES.pick_random()
	GameManager.add_score(points)

	await get_tree().create_timer(0.5, false).timeout
	sprite_2d.hide()
	_show_points(points)
	await get_tree().create_timer(1.0, false).timeout
	queue_free()


func _show_points(points: int):
	var label = Label.new()
	label.text = str(points)
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(120, 40)
	# undo the UFO's scale so the text renders at its normal size
	label.scale = Vector2.ONE / scale
	label.position = -label.size * label.scale / 2
	add_child(label)
