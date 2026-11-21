extends CanvasLayer

class_name Hud

# The HUD keeps processing while the game is paused so it can handle the pause menu.

const LIFE_ICON = preload("res://Assets/Player/Player.png")
const START_SCREEN = "res://Scenes/start_screen.tscn"

# Everything below this y (in screen units) is the touch-control area.
const CONTROL_AREA_TOP = 870.0
const BUTTON_TEXTURE_SIZE = 32.0
const MAX_BUTTON_SIZE = 210.0

@onready var score_label = %ScoreLabel
@onready var high_score_label = %HighScoreLabel
@onready var wave_label = %WaveLabel
@onready var lives_label = %LivesLabel
@onready var lives_icons = %LivesIcons
@onready var message_label = %MessageLabel
@onready var menu_buttons = %MenuButtons
@onready var resume_button = %ResumeButton
@onready var restart_button = %RestartButton
@onready var dim = %Dim
@onready var keyboard_hint = %KeyboardHint
@onready var left_button = %LeftButton
@onready var right_button = %RightButton
@onready var fire_button = %FireButton

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

	keyboard_hint.visible = not DisplayServer.is_touchscreen_available()
	get_viewport().size_changed.connect(_layout_touch_controls)
	_layout_touch_controls()


# Big buttons filling the strip under the playfield: move left/right on the left,
# fire on the right, with a clear gap between them so thumbs don't hit the wrong one.
func _layout_touch_controls():
	var view = get_viewport().get_visible_rect().size
	var area_height = view.y - CONTROL_AREA_TOP
	var margin = 24.0
	var gap = 20.0
	var button_size = clamp(area_height - 2 * margin, 120.0, MAX_BUTTON_SIZE)
	var y = CONTROL_AREA_TOP + (area_height - button_size) / 2
	var button_scale = Vector2.ONE * button_size / BUTTON_TEXTURE_SIZE
	for button in [left_button, right_button, fire_button]:
		button.scale = button_scale
	left_button.position = Vector2(margin, y)
	right_button.position = Vector2(margin + button_size + gap, y)
	fire_button.position = Vector2(view.x - margin - button_size, y)


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
		show_message("PAUSED", true)
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
	show_message("GAME OVER", true)


# with_menu = true shows the dimmed backdrop and the Resume/Restart/Menu buttons
# (used for pause and game over, not for "WAVE n").
func show_message(text: String, with_menu: bool = false):
	message_label.text = text
	message_label.show()
	dim.visible = with_menu
	menu_buttons.visible = with_menu
	resume_button.visible = not is_game_over
	restart_button.text = " PLAY AGAIN (R) " if is_game_over else " RESTART (R) "


func hide_message():
	message_label.hide()
	menu_buttons.hide()
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
