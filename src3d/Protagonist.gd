extends Puppet

const TrackRecorder = preload("res://TrackRecorder.gd")

const SIDE_WIDTH = 2


onready var player = $AnimationPlayer

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

var isJumping = false
var isOverjumping = false

var allTime = 0
var allDistance = 0

var startJumpDistance = 0
var startOverjumpDistance = 0

var trackRecorder : TrackRecorder = null

func _ready():
	pass

func start_record(mode):
	trackRecorder = TrackRecorder.new()
	runnerMode = mode
	if runnerMode == RunnerMode.SINGLE:
		xPosition = SINGLE_X_POS
	else:
		xPosition = HERO_X_POS

func _physics_process(delta):
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

func jump():
	if movingLeft or movingRight or isJumping:
		return
	if trackRecorder != null:
		trackRecorder.jump(allTime)
	startJumpDistance = allDistance
	isJumping = true
	movingUp = true
	player.play("Overjumping")

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

func die():
	if trackRecorder != null:
		trackRecorder.die(allTime)

func finish():
	if trackRecorder != null:
		trackRecorder.finish(allTime)

func score(value):
	if trackRecorder != null:
		trackRecorder.score(allTime, value)


func get_track():
	return trackRecorder.get_track()

func _on_AnimationPlayer_animation_finished(anim_name):
	player.play("Running")
	isJumping = false
