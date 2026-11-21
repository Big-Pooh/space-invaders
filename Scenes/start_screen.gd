extends CanvasLayer

@onready var invader_1_texture = %Invader1Texture
@onready var invader_1_label = %Invader1Label
@onready var invader_2_texture = %Invader2Texture
@onready var invader_2_label = %Invader2Label
@onready var invader_3_texture = %Invader3Texture
@onready var invader_3_label = %Invader3Label
@onready var high_score_label = %HighScoreLabel
@onready var play_button = %Button

@onready var timer = $Timer


var control_array = []


func _ready():
	control_array.append_array([invader_1_texture,invader_1_label,invader_2_texture,invader_2_label,invader_3_texture,invader_3_label])

	for control in control_array:
		(control as Control).modulate = Color.TRANSPARENT

	high_score_label.text = "HI-SCORE  %04d" % GameManager.high_score
	# Focus the button so Enter / Space starts the game.
	play_button.grab_focus()

	# The game is laid out for portrait; on a phone held sideways it's tiny, so suggest turning it.
	if DisplayServer.is_touchscreen_available():
		get_tree().root.size_changed.connect(_update_rotate_tip)
		_update_rotate_tip()


var rotate_tip: Label

func _update_rotate_tip():
	var window_size = get_tree().root.size
	var landscape = window_size.x > window_size.y
	if landscape and rotate_tip == null:
		rotate_tip = Label.new()
		rotate_tip.text = "TURN YOUR PHONE UPRIGHT TO PLAY"
		rotate_tip.add_theme_font_override("font", preload("res://Assets/font/andina.ttf"))
		rotate_tip.add_theme_font_size_override("font_size", 36)
		rotate_tip.add_theme_color_override("font_color", Color(1, 1, 0.4))
		rotate_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rotate_tip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		rotate_tip.offset_top = -60
		rotate_tip.offset_bottom = -12
		add_child(rotate_tip)
	elif rotate_tip:
		rotate_tip.visible = landscape


func load_game():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func show_next_control():
	var control = control_array.pop_front() as Control
	if control != null:
		control.modulate = Color.WHITE
	else:
		timer.stop()
		timer.queue_free()
