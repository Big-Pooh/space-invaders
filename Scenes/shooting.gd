extends Node2D

# Only one laser can be on screen at a time. To keep firing responsive on touch screens:
# - holding Fire keeps shooting as soon as the previous laser is gone
# - a tap while a laser is still flying is remembered for a short time and fires when possible

const TAP_BUFFER_TIME = 0.8  # about the longest a laser can be in flight

@export var laser_scene : PackedScene

@onready var player: Player = get_parent()

var can_player_shoot = true
var buffered_tap_time = 0.0


func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		buffered_tap_time = TAP_BUFFER_TIME
		try_shoot()


func _process(delta):
	buffered_tap_time = max(buffered_tap_time - delta, 0.0)
	if Input.is_action_pressed("shoot") or buffered_tap_time > 0.0:
		try_shoot()


func try_shoot():
	if not can_player_shoot or not player.can_shoot():
		return
	can_player_shoot = false
	buffered_tap_time = 0.0
	var laser = laser_scene.instantiate() as Laser
	laser.global_position = global_position - Vector2(0, 20)
	get_tree().current_scene.add_child(laser)
	laser.tree_exited.connect(on_laser_destroyed)
	Sfx.play("shoot", -6.0)


func on_laser_destroyed():
	can_player_shoot = true
