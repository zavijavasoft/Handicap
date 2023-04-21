extends Node

const  MUSIC_RESOURCES = [
	preload("res://sounds/music-theme.mp3"),
]

const SFX_RESOURCES = [
	preload("res://sounds/bonus.wav"), #_CLICK
	preload("res://sounds/death.wav"),
	preload("res://sounds/jump.wav"),
	preload("res://sounds/lose-race.wav"),
	preload("res://sounds/click-switch.wav"),
	preload("res://sounds/fall.wav"),
	preload("res://sounds/wall.wav"),
	preload("res://sounds/gate.wav"),
]


enum Sfx {
	BONUS = 0,
	DEATH = 1,
	JUMP = 2,
	LOSE = 3,
	CLICK = 4,
	FALL = 5,
	WALL = 6,
	GATE = 7,
	LAST_SFX = 8,
}

var musicPlayer = AudioStreamPlayer.new()
var sfxPlayer = AudioStreamPlayer.new()

func _init():
	pass

func _ready():
	sfxPlayer.volume_db = -2.0
	musicPlayer.volume_db = -2.5
	add_child(sfxPlayer)
	add_child(musicPlayer)
	pass

func on_sound_button_pressed(button_pressed):
	G.soundOn = !button_pressed
	G.musicOn = !button_pressed
	if button_pressed:
		G.reach_goal("sound_off")
		stop_music()
	else:
		G.reach_goal("sound_on")
		play_music()
	pass # Replace with function body.

func play_sfx(sfx_id):
	if not G.soundOn:
		return
	sfxPlayer.stream = SFX_RESOURCES[sfx_id]
	sfxPlayer.play()

func play_music():
	if not G.musicOn:
		return
		
	if not musicPlayer.is_playing():
		musicPlayer.stream = MUSIC_RESOURCES[0]
		musicPlayer.play()
	
func stop_music():
	musicPlayer.stop()
