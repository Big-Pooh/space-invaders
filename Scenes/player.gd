extends Area2D

class_name Player

# Emitted the moment the player is hit.
signal hit_taken
# Emitted when the destroy animation has finished playing.
signal destroyed

const INVULNERABLE_TIME = 2.0

@export var speed = 200
var direction = Vector2.ZERO

@onready var collision_rect : CollisionShape2D = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

var bounding_size_x
var start_bound
var end_bound

var start_position: Vector2
var default_texture: Texture2D
var is_dead = false
var is_invulnerable = false
var blink_tween: Tween


func _ready():
	bounding_size_x = collision_rect.shape.get_rect().size.x
	start_position = position
	default_texture = sprite_2d.texture
	animation_player.animation_finished.connect(_on_animation_finished)

	var rect = get_viewport().get_visible_rect()
	var camera = get_viewport().get_camera_2d()
	var camera_position = camera.position
	start_bound = camera_position.x - rect.size.x / 2
	end_bound = camera_position.x + rect.size.x / 2


func _process(delta):
	if is_dead:
		return

	var input = Input.get_axis("move_left","move_right")

	if input > 0 :
		direction = Vector2.RIGHT
	elif input < 0 :
		direction = Vector2.LEFT
	else :
		direction = Vector2.ZERO

	var delta_movement = speed * delta * direction.x

	# check if going out of screen bounds
	if position.x + delta_movement < start_bound + bounding_size_x * transform.get_scale().x || position.x + delta_movement > end_bound - bounding_size_x * transform.get_scale().x :
		return

	position.x += delta_movement


func can_shoot() -> bool:
	return not is_dead


func can_be_hit() -> bool:
	return not is_dead and not is_invulnerable


# force = true ignores invulnerability (used when invaders reach the bottom).
func on_player_destroyed(force: bool = false):
	if is_dead or (is_invulnerable and not force):
		return
	is_dead = true
	_stop_blinking()
	animation_player.play("destroy")
	Sfx.play("player_explosion", -4.0)
	hit_taken.emit()


func respawn():
	animation_player.stop()
	sprite_2d.texture = default_texture
	sprite_2d.show()
	position = start_position
	is_dead = false
	_stop_blinking()
	is_invulnerable = true
	blink_tween = create_tween().set_loops(int(INVULNERABLE_TIME / 0.2))
	blink_tween.tween_property(sprite_2d, "modulate:a", 0.2, 0.1)
	blink_tween.tween_property(sprite_2d, "modulate:a", 1.0, 0.1)
	blink_tween.finished.connect(_stop_blinking)


func _stop_blinking():
	if blink_tween:
		blink_tween.kill()
		blink_tween = null
	sprite_2d.modulate.a = 1.0
	is_invulnerable = false


func _on_animation_finished(anim_name):
	if anim_name == "destroy":
		sprite_2d.hide()
		destroyed.emit()
