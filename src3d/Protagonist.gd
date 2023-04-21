extends Puppet

signal sig_finished
signal sig_scored(is_hero, score)
signal sig_scored_multi(is_hero, score)

const TrackRecorder = preload("res://TrackRecorder.gd")
const Doll = preload("res://Doll.gd")
const Gate = preload("res://Gate.gd")

onready var timer = $Timer
onready var nameLabel = $NameLabel
var soundPlayer : SoundController

var timerCount = 0

var score_count : int = 0

const SIDE_WIDTH = 2

var character : Doll

var jumpRatio = PI / 7.333333
var jumpVelocity = Vector3.ZERO
var gravity = Vector3(0, -9.8, 0)

var movingRight = false
var movingLeft = false
var movingUp = false
var currentLine = 0
var xPosition = FOE_X_POS

var camera = null
var runnerMode = RunnerMode.FOE
var deathReason = 0
var paused = false

var allTime = 0
var allDistance = 0

var startJumpDistance = 0
var startOverjumpDistance = 0
var isInvulnerable = false

var trackRecorder : TrackRecorder = null

func _ready():
	connect("sig_scored", get_parent(), "_on_Scored")
	pass

func apply_character(charResource):
	if character != null:
		character.disconnect("sig_finished", get_parent(), "_on_Level_Finished")
		remove_child(character)
	var CharacterSc = load(charResource)
	character = CharacterSc.instance() as Doll
	add_child(character)
	character.connect("sig_finished", get_parent(), "_on_Level_Finished")


func zombify():
	$AreaHero.collision_mask = 0
	$AreaHero.collision_layer = 0
	

func set_runner_mode(mode):
	var charResource
	var sigFlag = true
	nameLabel.text = G.userName
	runnerMode = mode
	match mode:
		RunnerMode.SINGLE:
			charResource = "res://" + G.characterModelName + ".tscn"
			xPosition = SINGLE_X_POS
			pass
		RunnerMode.HERO:
			charResource = "res://" + G.characterModelName + ".tscn"
			xPosition = HERO_X_POS
			pass
		RunnerMode.FOE:
			sigFlag = false
			$AreaHero.collision_mask = 2
			$AreaHero.collision_layer = 2
			nameLabel.text = G.foeName
			charResource = "res://" + G.foeModelName + ".tscn"
			xPosition = FOE_X_POS
			pass
	apply_character(charResource)
	emit_signal("sig_scored", sigFlag, 0)
	if mode != RunnerMode.FOE:
		trackRecorder = TrackRecorder.new()
	translation.x = xPosition

func start_record(mode):
	allTime = 0


func _physics_process(delta):
	if paused:
		return
	allTime = allTime + delta
	if movingRight:
		if translation.x <= xPosition - SIDE_WIDTH:
			movingRight = false
		elif currentLine == 0 and translation.x <= xPosition:
			movingRight = false
		else:
			var sideShift = Vector3(-sideVelocity * delta, 0, 0)
			translate(sideShift)
			shift_camera(-sideShift)
	elif movingLeft:
		if translation.x >= xPosition + SIDE_WIDTH:
			movingLeft = false
		elif currentLine == 0 and translation.x >= xPosition:
			movingLeft = false
		else:
			var sideShift = Vector3(sideVelocity * delta, 0, 0)
			translate(sideShift)
			shift_camera(-sideShift)
	
	var jumpHeight = 0
	if movingUp:
		jumpVelocity = Vector3(0, 4, 0)
		movingUp = false
	translate(jumpVelocity * delta)
	jumpVelocity += gravity * delta
	translation.y = clamp(translation.y, 0, 3)

func shift_camera(sideShift):
	if camera != null:
		camera.translate(sideShift)

func run():
	character.run()

func jump():
	if movingLeft or movingRight or character.isJumping:
		return
	if trackRecorder != null:
		trackRecorder.jump(allTime)
	startJumpDistance = allDistance
	movingUp = true
	character.jump()

func move_left():
	if movingRight or currentLine == 1:
		return
	movingLeft = true
	currentLine += 1
	if trackRecorder != null:
		trackRecorder.move_left(allTime)
	pass
	
func move_right():
	if movingLeft or currentLine == -1:
		return
	movingRight = true
	currentLine -= 1
	if trackRecorder != null:
		trackRecorder.move_right(allTime)
	pass

func die(reason):
	if trackRecorder != null:
		trackRecorder.die(allTime, reason)
	deathReason = character.die(reason)

func finish():
	nameLabel.visible = false
	if trackRecorder != null:
		trackRecorder.finish(allTime)

func score(newValue):
	var isHero = false
	score_count = newValue
	if trackRecorder != null:
		isHero = true
		trackRecorder.score(allTime, score_count)
	emit_signal("sig_scored", isHero, score_count)

func reborn():
	if trackRecorder != null:
		trackRecorder.reborn(allTime)
	character.reborn()
	timer.start()
	isInvulnerable = true
	
func respawn():
	if trackRecorder != null:
		trackRecorder.respawn(allTime)
	character.respawn()
		

func get_track():
	return trackRecorder.get_track()

func _on_AreaHero_area_entered(area):
	if area.name == "FinishArea":
		print("Finished!!!!")
		if trackRecorder != null:
			trackRecorder.finish(allTime)
			get_parent().upload_track(trackRecorder.get_track())
			
		character.isFinishing = true
		nameLabel.visible = false
	elif area.name in [ "PikeSetArea", "ColumnArea", "AbyssArea" ]:
		if is_dead() or is_reborn() or isInvulnerable:
			return
		die(area.name)
		var tax = 100 * floor(allTime / 10)
		var after = clamp(score_count - tax, 0, score_count)
		print("Tax : ", score_count, "," ,tax , ", ", after, ", ", allTime)
		score(after)
	elif area.name == "GateArea":
		if is_dead() or is_reborn() or isInvulnerable:
			return
		var gate = area.get_parent()
		SoundController.play_sfx(SoundController.Sfx.GATE)
		gate.pickup()
		var newValue = gate.change_score(score_count)
		score(newValue)
	elif area.name == "CounterArea":
		if is_dead() or is_reborn() or isInvulnerable:
			return
		SoundController.play_sfx(SoundController.Sfx.BONUS)
		var increment = area.get_parent().pickup()
		if trackRecorder != null:
			score(increment + score_count)
		pass
	
	pass # Replace with function body.

func is_stopped():
	return character.isStopped
	
func is_dead():
	return character.isDead

func is_reborn():
	return character.isReborn


func _on_Timer_timeout():
	timerCount += 1
	if timerCount >= 25:
		timerCount = 0
		isInvulnerable = false
		character.visible = true
		timer.stop()
		return
	character.visible = !character.visible
	pass # Replace with function body.
