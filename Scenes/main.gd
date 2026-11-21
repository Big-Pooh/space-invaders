extends Node

# Runs a game session: waves, player deaths/respawns and game over.

enum State { PLAYING, PLAYER_DEAD, WAVE_CLEARED, GAME_OVER }

const WAVE_CLEAR_DELAY = 2.0

@onready var player: Player = $Player
@onready var invader_spawner: Invader_Spawner = $InvaderSpawner
@onready var ufo_spawner = $UfoSpawner
@onready var bottom_wall: Area2D = $Walls/BottomWall
@onready var hud: Hud = $HUD

var state = State.PLAYING


func _ready():
	GameManager.reset()
	player.hit_taken.connect(_on_player_hit)
	player.destroyed.connect(_on_player_destroyed)
	invader_spawner.all_invaders_destroyed.connect(_on_wave_cleared)
	bottom_wall.area_entered.connect(_on_bottom_wall_area_entered)
	start_wave()


func start_wave():
	state = State.PLAYING
	invader_spawner.start_wave(GameManager.wave)
	ufo_spawner.set_active(true)
	hud.show_message("WAVE %d" % GameManager.wave)
	await get_tree().create_timer(1.5, false).timeout
	if state != State.GAME_OVER:
		hud.hide_message()


func clear_enemy_projectiles():
	get_tree().call_group("enemy_projectile", "queue_free")


func _on_player_hit():
	# Freeze the invaders while the player explodes.
	if state == State.PLAYING:
		state = State.PLAYER_DEAD
	invader_spawner.set_active(false)
	ufo_spawner.set_active(false)


func _on_player_destroyed():
	if state == State.GAME_OVER:
		return
	GameManager.lose_life()
	if GameManager.lives <= 0:
		game_over()
		return
	clear_enemy_projectiles()
	player.respawn()
	if state == State.PLAYER_DEAD:
		state = State.PLAYING
		invader_spawner.set_active(true)
		ufo_spawner.set_active(true)


func _on_wave_cleared():
	if state == State.GAME_OVER:
		return
	state = State.WAVE_CLEARED
	ufo_spawner.set_active(false)
	await get_tree().create_timer(WAVE_CLEAR_DELAY, false).timeout
	if state != State.WAVE_CLEARED:
		return
	clear_enemy_projectiles()
	GameManager.next_wave()
	start_wave()


func _on_bottom_wall_area_entered(area):
	# Invaders reaching the ground ends the game, whatever lives are left.
	if area is Invader and state != State.GAME_OVER:
		GameManager.lose_all_lives()
		invader_spawner.stop()
		# Game over is shown once the explosion finishes (lives are now 0).
		if not player.is_dead:
			player.on_player_destroyed(true)


func game_over():
	state = State.GAME_OVER
	invader_spawner.stop()
	ufo_spawner.set_active(false)
	GameManager.save_high_score()
	hud.show_game_over()
