extends Node

# Global sound player (autoload "Sfx"). Usage: Sfx.play("shoot")

const SOUNDS = {
	"shoot": preload("res://Assets/Sounds/shoot.wav"),
	"invader_killed": preload("res://Assets/Sounds/invader_killed.wav"),
	"player_explosion": preload("res://Assets/Sounds/player_explosion.wav"),
	"ufo_killed": preload("res://Assets/Sounds/ufo_killed.wav"),
}

const MARCH = [
	preload("res://Assets/Sounds/march_1.wav"),
	preload("res://Assets/Sounds/march_2.wav"),
	preload("res://Assets/Sounds/march_3.wav"),
	preload("res://Assets/Sounds/march_4.wav"),
]

const POOL_SIZE = 8

var pool: Array[AudioStreamPlayer] = []
var march_player: AudioStreamPlayer
var march_index = 0


func _ready():
	for i in POOL_SIZE:
		var player = AudioStreamPlayer.new()
		add_child(player)
		pool.append(player)
	march_player = AudioStreamPlayer.new()
	add_child(march_player)


func play(sound_name: String, volume_db: float = 0.0):
	if not SOUNDS.has(sound_name):
		push_warning("Unknown sound: %s" % sound_name)
		return
	for player in pool:
		if not player.playing:
			player.stream = SOUNDS[sound_name]
			player.volume_db = volume_db
			player.play()
			return


# Plays the next note of the 4-note invader march.
func play_march_step():
	march_player.stream = MARCH[march_index]
	march_player.play()
	march_index = (march_index + 1) % MARCH.size()


func reset_march():
	march_index = 0
