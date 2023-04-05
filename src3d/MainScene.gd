extends Spatial

const FlatwaySc = preload("res://Flatway.tscn")
const WorldGenerator = preload("res://WorldGenerator.gd")
const Protagonist = preload("res://Protagonist.gd")
const TrackExecutor = preload("res://TrackExecutor.gd")

const HERO_X_POS = -0.5
const FOE_X_POS = -0.5
const SIDE_WIDTH = 2
const FRAGMENT_COUNT = 10

onready var wayFragments = [$FlatwayStart1, $FlatwayStart2, $FlatwayStart3, $FlatwayStart4]
onready var hero = $Protagonist
onready var foe = $Foe
onready var camera = $Camera

var runVelocity = 8.0
var keyboardMovePending = false
var trackExecutor

var allTime = 0
var allDistance = 0
var wayFragmentsUsed = 4

var generator : WorldGenerator

func _ready():
	generator = WorldGenerator.new()
	generator.set_seed(100)
	hero.camera = camera
	hero.start_record(Protagonist.RunnerMode.HERO)
	trackExecutor = TrackExecutor.new()
	trackExecutor.start_execute(foe)
	pass

func _physics_process(delta):
	allTime += delta
	trackExecutor.fake_physics_process(delta)
	var shift = Vector3(0, 0, -runVelocity * delta)
	allDistance += -shift.z
	hero.allDistance = allDistance
	for fragment in wayFragments:
		fragment.translate(shift)
	if wayFragments[0].translation.z < -20 and wayFragmentsUsed < FRAGMENT_COUNT:
		wayFragmentsUsed += 1
		var finish = false
		if wayFragmentsUsed == FRAGMENT_COUNT:
			finish = true
		var newWay = generator.create_new_way_fragment(wayFragments.back(), finish)

		add_child(newWay)
		wayFragments.append(newWay)
		remove_child(wayFragments.front())
		wayFragments.remove(0)
	pass

func _input(event):
	if event.is_action_pressed("ui_right"):
		hero.move_right()
		keyboardMovePending = true
	if event.is_action_released("ui_right"):
		keyboardMovePending = false
	if event.is_action_pressed("ui_left"):
		hero.move_left()
		keyboardMovePending = true
	if event.is_action_released("ui_left"):
		keyboardMovePending = false
	if event.is_action_pressed("ui_up"):
		hero.jump()
		keyboardMovePending = true
	if event.is_action_pressed("ui_up"):
		keyboardMovePending = false
	pass



func _on_SwipeDetector_sig_swiped(direction):
	match (direction):
		0: hero.jump()
		1: hero.move_right()
		-1: hero.move_left()
	pass # Replace with function body.
