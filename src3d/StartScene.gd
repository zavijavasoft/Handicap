extends BaseScene

const Protagonist = preload("res://Protagonist.gd")

onready var hero = $Protagonist
onready var startButton = $Control/StartButton
onready var languageButton = $Control/LanguageButton
onready var startLabel = $Control/StartButton/StartLabel
onready var languageLabel = $Control/LanguageButton/LanguageLabel
onready var ratingLabel = $Control/RatingLabel
onready var ratingTitleLable = $Control/RatingLabel/RatingTitleLabel
onready var rewardedSeed1 = $Control/RatingLabel/RewardedSeed1st
onready var rewardedSeed2 = $Control/RatingLabel/RewardedSeed2nd
onready var rewardedSeed3 = $Control/RatingLabel/RewardedSeed3rd
onready var labelExplain = $Control/RatingLabel/LabelExplain

var previousCharacter = "Alyona"
var timeCount = 5
var rewardSeed1 = 0
var rewardSeed2 = 0
var rewardSeed3 = 0
var rewardedShown = -1
var seedForReward = 0
#var generator = RandomNumberGenerator.new()

func _ready():
	hero.nameLabel.visible = false
	hero.set_runner_mode(Protagonist.RunnerMode.SINGLE)
	hero.run()
	G.connect("sig_locale_changed", self, "update_locale")
	G.connect("sig_yandex_login", self, "on_authorize")
	G.connect("sig_update_game_data", self, "on_update_game_data")
	_on_Layout_Update()
	on_update_game_data()
	
	if not G.soundOn:
		$Control/ButtonSound.pressed = true
	SoundController.play_music()

	pass

func _physics_process(delta):
	update_viewport_size()
	timeCount += delta
	if timeCount > 5:
		timeCount = 0
		var dt = OS.get_date()
		var tm = OS.get_time()
		rewardedSeed1.disabled = false
		rewardedSeed2.disabled = false
		rewardedSeed3.disabled = false
		var timeseed = tm.hour * dt.year * dt.month * dt.day

		rewardSeed1 = timeseed + 10
		rewardSeed2 = timeseed + 20
		rewardSeed3 = timeseed + 30
		if rewardSeed1 == G.firstRewardedSeed:
			rewardedSeed1.disabled = true
		if rewardSeed2 == G.secondRewardedSeed:
			rewardedSeed2.disabled = true
		if rewardSeed3 == G.thirdRewardedSeed:
			rewardedSeed3.disabled = true

func _on_Layout_Update():
	var midVp = viewportSize.size.x / 2
	startButton.set_position(Vector2(midVp - startButton.get_rect().size.x / 2,
										 startButton.get_position().y))
	languageButton.set_position(Vector2(viewportSize.size.x - languageButton.get_rect().size.x,
										 languageButton.get_position().y))
	ratingLabel.set_position(Vector2(midVp - ratingLabel.get_rect().size.x / 2,
										 ratingLabel.get_position().y))
	pass


func _on_StartButton_pressed():
	G.reach_goal("start_race_button_clicked")
	G.reach_goal("run_with_" + G.characterModelName)
	SoundController.play_sfx(SoundController.Sfx.CLICK)
	NetManager.findTrack()
	if (previousCharacter != G.characterModelName):
		G.save_game()
	SoundController.stop_music()
	G.switch_to_main_scene()


func _on_LanguageButton_pressed():
	SoundController.play_sfx(SoundController.Sfx.CLICK)
	if G.userSelectedLanguage.empty():
		G.userSelectedLanguage = G.language
	for i in G.languages.size():
		if G.languages[i] == G.userSelectedLanguage:
			i = (i + 1) % G.languages.size()
			G.userSelectedLanguage = G.languages[i]
			G.language = G.languages[i]
			G.save_game()
			update_locale()
			break
	pass # Replace with function body.

func update_locale():
	TranslationServer.set_locale(G.language)
	languageLabel.text = tr("lang")
	startLabel.text = tr("start_run")
	ratingTitleLable.text = tr("rating_title")
	labelExplain.text = tr("rewarded")
	$Control/YandexLoginButton.update_control()
	
	match G.language:
		"ru":
			languageButton.texture_normal = load("res://images/flag_ru_normal.png")
			languageButton.texture_pressed = load("res://images/flag_ru_pressed.png")
		"en":
			languageButton.texture_normal = load("res://images/flag_en_normal.png")
			languageButton.texture_pressed = load("res://images/flag_en_pressed.png")
		"tr":
			languageButton.texture_normal = load("res://images/flag_tr_normal.png")
			languageButton.texture_pressed = load("res://images/flag_tr_pressed.png")
	pass

func on_authorize():
	$Control/YandexLoginButton.update_control()
	
func on_update_game_data():
	previousCharacter = G.characterModelName
	ratingLabel.text = str(G.eloRating)
	for i in G.gameCharacters.size():
		if G.characterModelName == G.gameCharacters[i]:
			var charResource = "res://" + G.characterModelName + ".tscn"
			G.foeModelName = G.gameCharacters[(i + 1) % G.gameCharacters.size()]
			hero.apply_character(charResource)
			hero.run()
	update_locale()


func _on_RightHeroButton_pressed():
	G.reach_goal("change_model_clicked")
	previousCharacter = G.characterModelName
	for i in G.gameCharacters.size():
		if previousCharacter == G.gameCharacters[i]:
			G.characterModelName = G.gameCharacters[(i + 1) % G.gameCharacters.size()]
			G.foeModelName = previousCharacter
			var charResource = "res://" + G.characterModelName + ".tscn"
			hero.apply_character(charResource)
			hero.run()
			


func _on_LeftHeroButton_pressed():
	G.reach_goal("change_model_clicked")
	previousCharacter = G.characterModelName
	for i in G.gameCharacters.size():
		if previousCharacter == G.gameCharacters[i]:
			G.characterModelName = G.gameCharacters[(i + G.gameCharacters.size() - 1) % G.gameCharacters.size()]
			G.foeModelName = previousCharacter
			var charResource = "res://" + G.characterModelName + ".tscn"
			hero.apply_character(charResource)
			hero.run()


func _on_RewardedSeed1st_pressed():
	G.reach_goal("reward_1_clicked")
	G.reach_goal("run_with_" + G.characterModelName)
	SoundController.stop_music()
	rewardedShown = 1
	seedForReward = rewardSeed1
	G.platformApi.show_rewarded_video(self, "_on_RewardedVideoShown")


func _on_RewardedSeed2nd_pressed():
	G.reach_goal("reward_2_clicked")
	SoundController.stop_music()
	rewardedShown = 2
	seedForReward = rewardSeed2
	G.platformApi.show_rewarded_video(self, "_on_RewardedVideoShown")


func _on_RewardedSeed3rd_pressed():
	G.reach_goal("reward_3_clicked")
	SoundController.stop_music()
	rewardedShown = 3
	seedForReward = rewardSeed3
	G.platformApi.show_rewarded_video(self, "_on_RewardedVideoShown")
	

func _on_RewardedVideoShown(rewarded):
	print ("Rewarded!!!")
	if (rewarded):
		match rewardedShown:
			1:
				G.reach_goal("reward_1_got")
				G.firstRewardedSeed = seedForReward
				rewardedSeed1.disabled = true
			2:
				G.reach_goal("reward_2_got")
				G.secondRewardedSeed = seedForReward
				rewardedSeed2.disabled = true
			3:
				G.reach_goal("reward_3_got")
				G.thirdRewardedSeed = seedForReward
				rewardedSeed3.disabled = true
		G.currentSeed = seedForReward
		G.foeTrack = ""
		G.trackLoadingPending = false
		SoundController.stop_music()
		G.switch_to_main_scene()
		G.save_game()

func _on_Scored():
	pass
