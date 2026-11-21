extends CanvasLayer

class_name Hud

# The HUD keeps processing while the game is paused so it can handle the pause menu.

const LIFE_ICON = preload("res://Assets/Player/Player.png")
const START_SCREEN = "res://Scenes/start_screen.tscn"

@onready var score_label = %ScoreLabel
@onready var high_score_label = %HighScoreLabel
@onready var wave_label = %WaveLabel
@onready var lives_label = %LivesLabel
@onready var lives_icons = %LivesIcons
@onready var message_label = %MessageLabel
@onready var hint_label = %HintLabel
@onready var dim = %Dim

var is_game_over = false


func _ready():
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.high_score_changed.connect(_on_high_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	_on_score_changed(GameManager.score)
	_on_high_score_changed(GameManager.high_score)
	_on_lives_changed(GameManager.lives)
	_on_wave_changed(GameManager.wave)
	hide_message()


func _unhandled_input(event):
	if is_game_over:
		if event.is_action_pressed("restart"):
			restart()
		elif event.is_action_pressed("menu") or event.is_action_pressed("pause"):
			go_to_menu()
		return

	if event.is_action_pressed("pause"):
		toggle_pause()
	elif get_tree().paused:
		if event.is_action_pressed("restart"):
			restart()
		elif event.is_action_pressed("menu"):
			go_to_menu()


func toggle_pause():
	var paused = not get_tree().paused
	get_tree().paused = paused
	if paused:
		show_message("PAUSED", "ESC  RESUME     R  RESTART     M  MENU")
	else:
		hide_message()


func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()


func go_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file(START_SCREEN)


func show_game_over():
	is_game_over = true
	show_message("GAME OVER", "R  PLAY AGAIN     M  MENU")


func show_message(text: String, hint: String = ""):
	message_label.text = text
	message_label.show()
	hint_label.text = hint
	hint_label.visible = hint != ""
	# dim the playfield behind menus (pause / game over), not behind "WAVE n"
	dim.visible = hint != ""


func hide_message():
	message_label.hide()
	hint_label.hide()
	dim.hide()


func _on_score_changed(score: int):
	score_label.text = "SCORE  %04d" % score


func _on_high_score_changed(high_score: int):
	high_score_label.text = "HI-SCORE  %04d" % high_score


func _on_wave_changed(wave: int):
	wave_label.text = "WAVE  %d" % wave


func _on_lives_changed(lives: int):
	lives_label.text = str(lives)
	for child in lives_icons.get_children():
		child.queue_free()
	# the ship on screen counts as one life, so show the reserve ones
	for i in max(lives - 1, 0):
		var icon = TextureRect.new()
		icon.texture = LIFE_ICON
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.custom_minimum_size = Vector2(39, 24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lives_icons.add_child(icon)
