extends Node

const AppID = "Handicap v" + str(YaVersion.MAJOR) + "." + str(YaVersion.MINOR) + "." + str(YaVersion.RELEASE)

signal sig_locale_changed
signal sig_yandex_login
signal sig_update_game_data
signal sig_leaderboard_updated

var platformApi : Node

var fixedScore = 0
var fixedBestScore = 0

# VARS TO STATS
var score : int = 0
var bestScore : int = 0
# END VARS TO STATS


# VARS TO SERIALIZE
var language = "ru"
var userSelectedLanguage = ""
var soundOn = true
var musicOn = true
var tutorialDone = false
var eloRating = 1000
var playerLevel = 0 # 0 - 10
var winCount = 0
var tieCount = 0
var firstTracksCount = 0
var achieveFirstBlood = false # For first win
var achieveFirstFriend = false # for first tie
var achievePioneer = false # for first 100 new seeds
var achieveIronStar = false # for first 100 wins
var achieveSilverStar = false # for first 500 wins
var achieveGoldStar = false # for first 1000 wins
var achievePlatinumStar = false # for first 5000 wins
var achieveNiobiumStar = false # for first 10000 wins
var achievePeaceMaker = false # for first 100 ties

# END VARS TO SERIALIZE

var userLoggedIn = false
var userName = "incognito"
var userUniqueId = ""
var avatarUrl = ""
var avatarImage = null
var avatarHTTPRequest = null

var currentScene = null
var currentProtagonist = "res://Alyona.tscn"

var currentSeed = 100
var lastTrack = ""
var foeName = "IUnknown"
var foeRating = 1000
var foeAvatarImage = null
var foeTrack = ""
var trackLoadingPending = false

var languages = ["ru", "en"]

func get_user_unique_id():
	if userUniqueId.empty():
		userUniqueId = Marshalls.utf8_to_base64(str(randi()))
	return userUniqueId

func _unhandled_key_input(event):
	if PApi.is_yandex_games_platform():
		if platformApi.try_handle_js_callback(event):
			return
	pass

func _init():
	randomize()
	rand_seed(OS.get_time().minute)
	avatarHTTPRequest = HTTPRequest.new()
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
	add_child(avatarHTTPRequest)
	avatarHTTPRequest.connect("request_completed", self, "_on_Avatar_request_completed")

func notify_track_received():
	pass

func setup_locale_externally(_lang):
	language = _lang
	if userSelectedLanguage != _lang and not userSelectedLanguage.empty():
		language = userSelectedLanguage
	TranslationServer.set_locale(language)
	emit_signal("sig_locale_changed")
	pass

	pass

func notify_yandex_sdk_loaded():
	AdvManager.showFullscreenAdv(self, "void_adv_callback")
	platformApi.get_leaderboard_entries()
	pass

func void_adv_callback(_adv_result):
	AdvManager.showBannerAdv()
	pass

func login_yandex_externally(playerName : String, _avatarUrl : String, uniqueId : String):
	userLoggedIn = true
	userName = playerName
	userUniqueId = uniqueId
	avatarUrl = _avatarUrl
	
	if not avatarUrl == null:
		avatarHTTPRequest.request(avatarUrl, [], HTTPClient.METHOD_GET)
	else:
		emit_signal("sig_yandex_login")

func _on_Avatar_request_completed(result, response_code, headers, body):
	avatarImage = Image.new()
	var image_error = avatarImage.load_jpg_from_buffer(body)
	if image_error != OK:
		avatarImage = null
		print("An error occurred while trying to display the image.")
	emit_signal("sig_yandex_login")

func notify_update_game_data():
	emit_signal("sig_update_game_data")
	pass

func notity_leaderboard_updated():
	emit_signal("sig_leaderboard_updated", platformApi.leaderboardEntries, platformApi.userLeaderboardRank)

func switch_to_main_scene():
	call_deferred("_deferred_switch_to_scene", "res://MainScene.tscn")
	pass

func switch_to_start_scene():
	call_deferred("_deferred_switch_to_scene", "res://StartScene.tscn")
	pass


func _deferred_switch_to_scene(pathToScene : String):
	currentScene.free()
	var s = ResourceLoader.load(pathToScene)
	currentScene = s.instance()
	get_tree().get_root().add_child(currentScene)
	get_tree().set_current_scene(currentScene)
	pass

func save_game():
	platformApi.save_game(serialize())
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
		tutorialDone = tutorialDone,
	}
	return to_json(save_dict)

func deserialize(gameData : String):
	if not gameData:
		return
	var data = parse_json(gameData)
	tutorialDone = data["tutorialDone"]
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

