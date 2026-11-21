extends Node2D

class_name Invader_Spawner

signal all_invaders_destroyed

#spawner configuration
const ROWS = 5
const COLUMNS = 11
const HORIZONTAL_SPACING = 32
const VERTICAL_SPACING = 32
const INVADER_HEIGHT = 24
const START_Y_POSITION = -50
const INVADERS_POSITION_X_INCREMENT = 10
const INVADERS_POSITION_Y_INCREMENT = 20

# difficulty
const BASE_MOVE_TIME = 0.25
const MIN_MOVE_TIME = 0.03
const WAVE_SPEEDUP = 0.88          # each wave moves 12% faster
const BASE_SHOT_TIME = 1.0
const MIN_SHOT_TIME = 0.4
const WAVE_START_Y_STEP = 16       # each wave starts a bit lower...
const MAX_WAVE_START_OFFSET = 64   # ...up to this many pixels

var movement_direction = 1
var invader_scene = preload("res://Scenes/invader.tscn")
var invader_shot_scene = preload("res://Scenes/invader_shot.tscn")
var invader_configs = [
	preload("res://Resources/invader_1.tres"),
	preload("res://Resources/invader_2.tres"),
	preload("res://Resources/invader_2.tres"),
	preload("res://Resources/invader_3.tres"),
	preload("res://Resources/invader_3.tres"),
]

var start_position: Vector2
var total_invaders = 0
var alive_invaders = 0
var wave_move_time = BASE_MOVE_TIME

#NODE REFERENCES
@onready var movement_timer = $MovementTimer
@onready var shot_timer = $ShotTimer


func _ready():
	start_position = position
	#SETUP TIMERS
	movement_timer.timeout.connect(move_invaders)
	shot_timer.timeout.connect(on_invader_shot)


func start_wave(wave: int):
	for child in get_children():
		if child is Invader:
			child.queue_free()

	position = start_position + Vector2(0, min((wave - 1) * WAVE_START_Y_STEP, MAX_WAVE_START_OFFSET))
	movement_direction = 1
	total_invaders = 0
	alive_invaders = 0
	Sfx.reset_march()

	for row in ROWS:
		var invader_config = invader_configs[row]
		var column_step = invader_config.width * 3 + HORIZONTAL_SPACING
		# centre each row around the spawner's origin
		var start_x = -((COLUMNS - 1) * column_step) / 2.0

		for col in COLUMNS:
			var x = start_x + col * column_step
			var y = START_Y_POSITION + (row * INVADER_HEIGHT) + (row * VERTICAL_SPACING)
			spawn_invader(invader_config, Vector2(x, y), col, row)

	wave_move_time = BASE_MOVE_TIME * pow(WAVE_SPEEDUP, wave - 1)
	shot_timer.wait_time = max(MIN_SHOT_TIME, BASE_SHOT_TIME - 0.1 * (wave - 1))
	update_speed()
	set_active(true)
	movement_timer.start()
	shot_timer.start()


func spawn_invader(invader_config, spawn_position: Vector2, col: int, row: int):
	var invader = invader_scene.instantiate() as Invader
	invader.config = invader_config
	invader.column = col
	invader.row = row
	invader.position = spawn_position
	invader.died.connect(_on_invader_died)
	add_child(invader)
	total_invaders += 1
	alive_invaders += 1


# Pauses or resumes marching and shooting (e.g. while the player explodes).
func set_active(active: bool):
	movement_timer.paused = not active
	shot_timer.paused = not active


func stop():
	movement_timer.stop()
	shot_timer.stop()


func update_speed():
	# Invaders speed up as their numbers drop.
	var fraction_alive = float(alive_invaders) / max(total_invaders, 1)
	movement_timer.wait_time = max(MIN_MOVE_TIME, wave_move_time * fraction_alive)


func _on_invader_died(_invader):
	alive_invaders -= 1
	update_speed()
	if alive_invaders <= 0:
		stop()
		all_invaders_destroyed.emit()


func move_invaders():
	position.x += INVADERS_POSITION_X_INCREMENT * movement_direction
	Sfx.play_march_step()


func _on_left_wall_area_entered(_area):
	if (movement_direction == -1) :
		position.y += INVADERS_POSITION_Y_INCREMENT
		movement_direction *= -1


func _on_right_wall_area_entered(_area):
	if (movement_direction == 1) :
		position.y += INVADERS_POSITION_Y_INCREMENT
		movement_direction *= -1


func get_alive_invaders() -> Array:
	return get_children().filter(func (child): return child is Invader and not child.is_dying)


func on_invader_shot():
	var alive = get_alive_invaders()
	if alive.is_empty():
		return
	# Only the lowest invader in a column fires, so shots never pass through other invaders.
	var shooter = alive.pick_random()
	for invader in alive:
		if invader.column == shooter.column and invader.row > shooter.row:
			shooter = invader
	var invader_shot = invader_shot_scene.instantiate() as InvaderShot
	invader_shot.global_position = shooter.global_position + Vector2(0, 20)
	get_tree().current_scene.add_child(invader_shot)
