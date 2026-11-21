extends Area2D

class_name Invader

signal died(invader: Invader)

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D

var config: InvaderResource
var column = 0
var row = 0
var is_dying = false


func _ready():
	sprite_2d.texture = config.sprite
	animation_player.play(config.animation_name)


# Called by the player's laser.
func hit():
	if is_dying:
		return
	is_dying = true
	# Stop blocking shots, triggering walls or eating bunkers while exploding.
	collision_shape.set_deferred("disabled", true)
	animation_player.play("destroy")
	GameManager.add_score(config.points)
	Sfx.play("invader_killed", -6.0)
	died.emit(self)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "destroy":
		queue_free()
