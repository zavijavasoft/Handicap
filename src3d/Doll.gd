extends Spatial
class_name Doll

signal sig_finished

onready var player = $AnimationPlayer

var isJumping = false
var isFinishing = false
var isFinished = false
var isStopped = false
var isDead = false
var isReborn = false
var isRespawn = false

func _ready():
	player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	pass

func run():
	player.play("Running")

func jump():
	SoundController.play_sfx(SoundController.Sfx.JUMP)
	player.play("Jumping")
	isJumping = true

func reborn():
	isDead = false
	isReborn = true
	player.playback_speed = 2.0
	player.play("Running")

func respawn():
	isDead = false
	isReborn = false
	player.playback_speed = 1.0
	player.play("Running")

func die(reason):
	isDead = true
	match reason:
		"PikeSetArea":
			SoundController.play_sfx(SoundController.Sfx.DEATH)
			player.play("FallFlat")
			return 0
		"AbyssArea":
			SoundController.play_sfx(SoundController.Sfx.FALL)
			player.play("HeadOverHills")
			return 2
		_:
			SoundController.play_sfx(SoundController.Sfx.WALL)
			player.play("FallBack")
			return 1
	
func play(animation):
	player.play(animation)

func _on_AnimationPlayer_animation_finished(anim_name):
	if isDead:
		isDead = false
		return
	if isReborn:
		player.playback_speed = 2.0
		player.play("Running")
		return

	player.playback_speed = 1.0
		
	if anim_name == "Dancing":
		player.play("Dancing")
		return
	if isFinished:
		isStopped = true
		emit_signal("sig_finished")
		player.play("Dancing")
		return
	if isFinishing:
		player.play("Jumping")
		isFinished = true
	else: 
		player.play("Running")
	isJumping = false
