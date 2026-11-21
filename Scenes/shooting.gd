extends Node2D

@export var laser_scene : PackedScene

@onready var player: Player = get_parent()

var can_player_shoot = true


func _unhandled_input(event):
	if event.is_action_pressed("shoot") and can_player_shoot and player.can_shoot():
		can_player_shoot = false
		var laser = laser_scene.instantiate() as Laser
		laser.global_position = global_position - Vector2(0, 20)
		get_tree().current_scene.add_child(laser)
		laser.tree_exited.connect(on_laser_destroyed)
		Sfx.play("shoot", -6.0)


func on_laser_destroyed():
	can_player_shoot = true
