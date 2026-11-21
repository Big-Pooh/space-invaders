extends Node

# Global game state (autoload "GameManager"): score, high score, lives, wave.

signal score_changed(score: int)
signal high_score_changed(high_score: int)
signal lives_changed(lives: int)
signal wave_changed(wave: int)

const START_LIVES = 3
const SAVE_PATH = "user://highscore.save"

var score = 0
var high_score = 0
var lives = START_LIVES
var wave = 1


func _ready():
	load_high_score()


func reset():
	score = 0
	lives = START_LIVES
	wave = 1
	score_changed.emit(score)
	lives_changed.emit(lives)
	wave_changed.emit(wave)
	high_score_changed.emit(high_score)


func add_score(points: int):
	score += points
	score_changed.emit(score)
	if score > high_score:
		high_score = score
		high_score_changed.emit(high_score)


func lose_life():
	lives = max(lives - 1, 0)
	lives_changed.emit(lives)


func lose_all_lives():
	lives = 0
	lives_changed.emit(lives)


func next_wave():
	wave += 1
	wave_changed.emit(wave)


func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)


func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_high_score()
