extends Node2D

# UFOs spawn just off-screen on a random side and fly across.
const SPAWN_X = 650

@onready var spawn_timer: SpawnTimer = $SpawnTimer
var ufo_scene: PackedScene = preload("res://Scenes/ufo.tscn")
var active = true


func _ready():
	spawn_timer.setup_timer()


func set_active(value: bool):
	active = value
	spawn_timer.paused = not value


func _on_spawn_timer_timeout():
	spawn_timer.setup_timer()  # pick a new random delay for the next UFO
	if not active or get_tree().get_nodes_in_group("ufo").size() > 0:
		return
	var ufo = ufo_scene.instantiate() as Ufo
	var from_left = randf() < 0.5
	ufo.direction = 1 if from_left else -1
	ufo.position = Vector2(-SPAWN_X if from_left else SPAWN_X, position.y)
	get_tree().current_scene.add_child(ufo)
