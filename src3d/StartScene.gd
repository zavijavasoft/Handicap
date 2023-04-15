extends BaseScene

onready var hero = $Protagonist
onready var startButton = $Control/StartButton
onready var languageButton = $Control/LanguageButton
onready var startLabel = $Control/StartButton/StartLabel
onready var languageLabel = $Control/LanguageButton/LanguageLabel

func _ready():
	hero.nameLabel.visible = false
	hero.run()
	G.connect("sig_locale_changed", self, "update_locale")
	_on_Layout_Update()


	if not G.soundOn:
		$Control/ButtonSound.pressed = true
	SoundController.play_music()

	pass

func _physics_process(delta):
	update_viewport_size()
	pass

func _on_Layout_Update():
	var midVp = viewportSize.size.x / 2
	startButton.set_position(Vector2(midVp - startButton.get_rect().size.x / 2,
										 startButton.get_position().y))
	languageButton.set_position(Vector2(viewportSize.size.x - languageButton.get_rect().size.x,
										 languageButton.get_position().y))
	pass


func _on_StartButton_pressed():
	SoundController.play_sfx(SoundController.Sfx.CLICK)
	NetManager.findTrack()
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
			update_locale(G.userSelectedLanguage)
			break
	pass # Replace with function body.

func update_locale(locale):
	print(locale)
	TranslationServer.set_locale(locale)
	languageLabel.text = tr("lang")
	startLabel.text = tr("start_run")
	match locale:
		"ru":
			languageButton.texture_normal = load("res://images/flag_ru_normal.png")
			languageButton.texture_pressed = load("res://images/flag_ru_pressed.png")
		"en":
			languageButton.texture_normal = load("res://images/flag_en_normal.png")
			languageButton.texture_pressed = load("res://images/flag_en_pressed.png")
	pass
