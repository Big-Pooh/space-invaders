extends Area2D

class_name InvaderShot

const FRAMES = [
	preload("res://Assets/Weapons/SpecialShot-1.png"),
	preload("res://Assets/Weapons/SpecialShot-2.png"),
	preload("res://Assets/Weapons/SpecialShot-3.png"),
	preload("res://Assets/Weapons/SpecialShot-4.png"),
]
const FRAME_TIME = 0.08

@export var speed = 200
# Shots disappear when they reach the ground line (below the player).
const GROUND_Y = 335
# Invader shots cycle through the SpecialShot frames; the UFO keeps the rocket sprite.
@export var animated = true

@onready var sprite_2d = $Sprite2D

var frame_timer = 0.0
var frame_index = 0


func _ready():
	add_to_group("enemy_projectile")
	if animated:
		sprite_2d.texture = FRAMES[0]


func _process(delta):
	position.y += speed * delta
	if position.y > GROUND_Y:
		queue_free()
		return
	if animated:
		frame_timer += delta
		if frame_timer >= FRAME_TIME:
			frame_timer -= FRAME_TIME
			frame_index = (frame_index + 1) % FRAMES.size()
			sprite_2d.texture = FRAMES[frame_index]


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	if area is Player:
		# Passes through the player while it's dead or blinking after a respawn.
		if area.can_be_hit():
			area.on_player_destroyed()
			queue_free()
	elif area.has_method("hit"):
		area.hit()
		queue_free()
