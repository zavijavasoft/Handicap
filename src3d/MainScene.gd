extends BaseScene

enum SceneState {
	WAITING,
	COUNTDOWN,
	RUN,
	FINISH,
	PAUSE
}

const FlatwaySc = preload("res://Flatway.tscn")
const WorldGenerator = preload("res://WorldGenerator.gd")
const Protagonist = preload("res://Protagonist.gd")
const TrackExecutor = preload("res://TrackExecutor.gd")
const FinishCurtain = preload("res://FinishCurtain.gd")


const HERO_X_POS = -0.5
const FOE_X_POS = -0.5
const SIDE_WIDTH = 2
const FRAGMENT_COUNT =  54

onready var wayFragments = [$FlatwayStart]
onready var hero = $Protagonist
onready var foe = $Foe
onready var camera = $Camera
onready var pauseButton = $ControlPanel/ButtonPause
onready var soundButton = $ControlPanel/ButtonSound
onready var finishCurtain = $ControlPanel/FinishCurtain
onready var waitingCurtain = $ControlPanel/WaitingCurtain
onready var labelHeroScore = $ControlPanel/ScoreLineHero
onready var labelFoeScore = $ControlPanel/ScoreLineFoe
onready var countDownLabel = $ControlPanel/CountDownLabel
onready var countDownTimer = $CountDownTimer
onready var selectorLabel = $ControlPanel/WaitingCurtain/SelectorLabel
onready var waitingLabel = $ControlPanel/WaitingCurtain/DotProgressLabel
onready var waitingTimer = $WaitingTimer
onready var progressBar = $ProgressBar


var runVelocity = 8.0
var keyboardMovePending = false
var trackExecutor

var state = SceneState.WAITING
var countDownTime = 5
var waitingTime = 1

var allTime = 0
var allDistance = 0
var wayFragmentsUsed = 1

var trackRecevied = true

var generator : WorldGenerator


func _init():
	G.connect("sig_yandex_login", self, "on_authorized")
	

func _ready():
	TranslationServer.set_locale(G.language)
	selectorLabel.text = tr("looking_for")
	state = SceneState.WAITING
	generator = WorldGenerator.new(G.currentSeed)
	hero.camera = camera

	_on_Layout_Update()
	soundButton.pressed = not G.soundOn
	SoundController.play_music()
	pass

func _physics_process(delta):
	update_viewport_size()
	match state:
		SceneState.WAITING:
			if wayFragmentsUsed < FRAGMENT_COUNT:
				wayFragmentsUsed += 1
				var finish = wayFragmentsUsed == FRAGMENT_COUNT
				var newWay = generator.create_new_way_fragment(wayFragments.back(), finish)
				add_child(newWay)
				wayFragments.append(newWay)
			elif not G.trackLoadingPending:
				waitingTimer.stop()
				state = SceneState.COUNTDOWN
				countDownTimer.start()
				waitingCurtain.hide()
				var runnerMode = Protagonist.RunnerMode.HERO
				if G.foeTrack.empty():
					foe.visible = false
					foe.zombify()
					G.foeRating = G.eloRating
					runnerMode = Protagonist.RunnerMode.SINGLE
					labelFoeScore.hide()
				else:
					foe.set_runner_mode(Protagonist.RunnerMode.FOE)
					labelFoeScore.set_hero_name(G.foeName)
				hero.set_runner_mode(runnerMode)
				labelHeroScore.set_hero_name(G.userName)
				pass
			pass
		SceneState.COUNTDOWN:
			pass
		SceneState.FINISH:
			final_dance_rotate(hero, delta)
			final_dance_rotate(foe, delta)
		SceneState.PAUSE:
			pass
		SceneState.RUN:
			allTime += delta
			trackExecutor.fake_physics_process(delta)
			var shift = Vector3(0, 0, -runVelocity * delta)
			allDistance += -shift.z
			progressBar.update_progress(allDistance / (FRAGMENT_COUNT * 20))
			hero.allDistance = allDistance
			for fragment in wayFragments:
				translate_way(fragment, shift)
			if wayFragments[0].translation.z < -20:
				remove_child(wayFragments.front())
				wayFragments.remove(0)
			control_protagonist(hero, shift)
			control_protagonist(foe, shift)

func control_protagonist(protagonist, shift):
	if protagonist.character == null:
		return
	if protagonist.is_dead():
		match protagonist.deathReason:
			0: 
				protagonist.translate(shift / 2.5)
			1: 
				protagonist.translate(shift)
			2: 
				protagonist.translate(0.9 * shift)
		if protagonist.translation.z <= -6:
			protagonist.reborn()
	elif protagonist.is_reborn():
		var fora = 0
		if protagonist.runnerMode == Protagonist.RunnerMode.HERO:
			fora = 0.25
		protagonist.translate(-4 * shift)
		protagonist.translation.z = clamp(protagonist.translation.z, -10, fora)
		if protagonist.translation.z >= 0:
			protagonist.respawn()

func run_game():
	state = SceneState.RUN
	G.reach_goal("race_started")
	hero.run()
	trackExecutor = TrackExecutor.new()
	if not G.foeTrack.empty():
		foe.run()
		hero.start_record(Protagonist.RunnerMode.HERO)
		trackExecutor.start_execute(foe, G.foeTrack)
	else:
		hero.start_record(Protagonist.RunnerMode.SINGLE)
		

func _input(event):
	if state != SceneState.RUN:
		return
	if hero.is_dead():
		return
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
	if event.is_action_released("ui_up"):
		keyboardMovePending = false
	pass

func translate_way(way, shift):
	way.translate(shift)
	if way.translation.z < camera.far + 10:
		generator.generate_obstacles(way)
	for element in way.get_children() :
		if not element is MeshInstance:
			if element.global_translation.z < -1.5:
				element.visible = false
	pass


func _on_SwipeDetector_sig_swiped(direction):
	match (direction):
		0: hero.jump()
		1: hero.move_right()
		-1: hero.move_left()
	pass # Replace with function body.

func _on_Level_Finished():
	state = SceneState.FINISH
	var foe_count = foe.score_count
	var hero_count = hero.score_count
	var mode = FinishCurtain.CurtainMode.WON
	if hero.runnerMode != Protagonist.RunnerMode.SINGLE:
		if hero.score_count < foe.score_count:
			mode = FinishCurtain.CurtainMode.DEFEAT
			SoundController.play_sfx(SoundController.Sfx.LOSE)
		elif hero.score_count == foe.score_count:
			mode = FinishCurtain.CurtainMode.TIE
	G.reach_goal("race_finished")
	finishCurtain.show_in_mode(mode)
	

func _on_Scored(isHero, score):
	if isHero:
		labelHeroScore.score(score)
	else:
		labelFoeScore.score(score)

func final_dance_rotate(protagonist, delta):
	if protagonist.rotation.y < -PI:
		return
	protagonist.rotate_y(-PI / 3 * delta)

func _on_Layout_Update():
	var labelsWidth = labelHeroScore.get_element_width()
	var heroLabelY = labelHeroScore.get_position().y
	var foeLabelY = labelFoeScore.get_position().y
	labelHeroScore.set_position(Vector2(viewportSize.size.x - labelsWidth, heroLabelY))
	labelFoeScore.set_position(Vector2(viewportSize.size.x - labelsWidth, foeLabelY))
	var midVp = viewportSize.size.x / 2
	waitingCurtain.set_position(Vector2(midVp - 512, 0))
	finishCurtain.set_position(Vector2(midVp - 512, 0))
	progressBar.set_position(Vector2(midVp - 512, 1880))
	countDownLabel.set_position(Vector2(midVp - countDownLabel.get_rect().size.x / 2,
										 countDownLabel.get_position().y))
	pass

func on_authorized():
	labelHeroScore.set_hero_name(G.userName)
	labelHeroScore.update()
	pass


func _on_CountDownTimer_timeout():
	countDownTime -= 1
	if countDownTime == -1:
		countDownLabel.visible = false
		countDownTimer.stop()
	elif countDownTime == 0:
		countDownLabel.text = "GO!"
		run_game()
	else:
		countDownLabel.text = str(countDownTime)
			
	pass 


func _on_WaitingTimer_timeout():
	if state == SceneState.WAITING:
		var dots = ""
		waitingTime = (waitingTime + 1) % 40
		
		for i in range(waitingTime):
			dots += "."
		waitingLabel.text = dots 
	pass 



func _on_ButtonPause_pressed():
	SoundController.play_sfx(SoundController.Sfx.CLICK)
	if state == SceneState.RUN:
		state = SceneState.PAUSE
		pauseButton.texture_normal = load("res://images/btn_continue_normal.png")
		pauseButton.texture_pressed = load("res://images/btn_continue_pressed.png")
		hero.paused = true
	elif state == SceneState.PAUSE:
		state = SceneState.RUN
		pauseButton.texture_normal = load("res://images/btn_pause_any.png")
		pauseButton.texture_pressed = load("res://images/btn_pause_hover.png")
		hero.paused = false
	pass # Replace with function body.


func upload_track(track):
	
	var Sa = 0.5
	if hero.score_count > foe.score_count:
		Sa = 1
	if hero.score_count < foe.score_count:
		Sa = 0
	
	var k = 20
	if G.eloRating > 2400:
		k = 10
	elif G.winCount + G.tieCount < 30:
		k = 40
	
	var Ea = 1 / (1 + pow(10, (G.foeRating - G.eloRating) / 400 ))
	var revenge = G.lastRating > 0
	G.lastRating = ceil(G.eloRating + k * (Sa - Ea))
	
	NetManager.uploadTrack(G.lastRating, G.currentSeed, 0, track)
	
	if not revenge:
		G.eloRating = G.lastRating
		if G.maxEloRating < G.eloRating or G.maxEloRating == null:
			G.maxEloRating = G.eloRating
			G.platformApi.set_leaderboard_entry(G.maxEloRating)
		G.save_game()
		G.lastRating = -1
	pass
