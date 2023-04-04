extends Node

signal sig_locale_changed
signal sig_yandex_login
signal sig_update_game_data
signal sig_leaderboard_updated

var platformApi : Node

var fixedScore = 0
var fixedBestScore = 0
#Vars to stats saving
var score : int = 0
var bestScore : int = 0

# Vars to serialize
var soundOn = true
var musicOn = true
var tutorialDone = false
var difficult = true
var cachedGame = ""
var cachedLocked = ""
var firstTry = true
# End vars to serialize

var userLoggedIn = false
var userName = "incognito"
var avatarUrl = ""
var avatarImage = null

var currentScene = null


func _unhandled_key_input(event):
	if PApi.is_yandex_games_platform():
		if platformApi.try_handle_js_callback(event):
			return
	pass

func _init():
	pass
	

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		#stop_music()
		return
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		#play_music()
		return

func _ready():
	platformApi = PApi.platformApi
	var root = get_tree().get_root()
	currentScene = root.get_child(root.get_child_count() - 1)


func setup_locale_externally(_lang):
#	emit_signal("sig_locale_changed")
	pass

func notify_yandex_sdk_loaded():
	platformApi.get_stats("['best', 'score']")
	AdvManager.showFullscreenAdv(self, "void_adv_callback")
	platformApi.get_leaderboard_entries()
	pass

func void_adv_callback(_adv_result):
	pass

func login_yandex_externally(playerName : String, _avatarUrl : String):
	userLoggedIn = true
	userName = playerName
	avatarUrl = _avatarUrl
	emit_signal("sig_yandex_login", playerName, avatarUrl)
	pass

func notify_update_game_data():
	emit_signal("sig_update_game_data")
	pass

func notity_leaderboard_updated():
	emit_signal("sig_leaderboard_updated", platformApi.leaderboardEntries, platformApi.userLeaderboardRank)

func switch_to_main_scene():
	call_deferred("_deferred_switch_to_scene", "res://MainScene.tscn")
	pass

func _deferred_switch_to_scene(pathToScene : String):
	currentScene.free()
	var s = ResourceLoader.load(pathToScene)
	currentScene = s.instance()
	get_tree().get_root().add_child(currentScene)
	get_tree().set_current_scene(currentScene)
	pass

func save_game():
	platformApi.save_game()
	pass
	
func load_game():
	platformApi.load_game()
	pass

func reach_goal(goal):
	platformApi.reachGoal(goal)

func serialize():
	var save_dict = {
		soundOn = soundOn,
		musicOn = musicOn,
		difficult = difficult,
		tutorialDone = tutorialDone,
		cachedGame = cachedGame,
		cachedLocked = cachedLocked,
		firstTry = firstTry,
	}
	return to_json(save_dict)

func deserialize(gameData : String):
	if not gameData:
		return
	var data = parse_json(gameData)
	soundOn = data["soundOn"]
	musicOn = data["musicOn"]
	tutorialDone = data["tutorialDone"]
	difficult = data["difficult"]
	cachedGame = data["cachedGame"]
	cachedLocked = data["cachedLocked"]
	firstTry = data["firstTry"]
	pass

func deserialize_stats(gameStats : String):
	var data = parse_json(gameStats)
	score = data["score"]
	bestScore = data["best"]
	if not score:
		score = 0
	if not bestScore:
		bestScore = 0
	fixedBestScore = bestScore
	fixedScore = score
	pass

func increment_stats():
	if score > bestScore:
		bestScore = score
		platformApi.set_leaderboard_entry(bestScore)
	var inc = {
		score = score - fixedScore,
		best = bestScore - fixedBestScore
	}
	platformApi.increment_stats(inc)

func dispatch_purchase(_id, _token):
	pass

