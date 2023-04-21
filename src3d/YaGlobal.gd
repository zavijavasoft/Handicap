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
var language = "en"
var userSelectedLanguage = ""
var soundOn = true
var musicOn = true
var tutorialDone = false
var eloRating = 1000
var maxEloRating = 1000
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
var characterModelName = "Alyona"
var firstRewardedSeed = 0
var secondRewardedSeed = 0
var thirdRewardedSeed = 0

# END VARS TO SERIALIZE

var userLoggedIn = false
var userName = "incognito"
var userUniqueId = ""
var avatarUrl = ""
var avatarImage = null
var avatarHTTPRequest = null

var currentScene = null

var gameCharacters = ["Alyona", "Geralt"]
var foeModelName = "Alyona"
var currentProtagonist = "res://Geralt.tscn"


var currentSeed = 100
var lastTrack = ""
var lastRating = -1
var foeName = "IUnknown"
var foeRating = 1000
var foeAvatarImage = null
var foeTrack = ""
var trackLoadingPending = false

var languages = ["ru", "en", "tr"]

var aliases = [
	"Incognito", "Невидимка", "Unknown Player", "Гость", "Guest", "Неизвестный", "Агент 008"
]

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
	userName = aliases[randi() % 7]
	avatarHTTPRequest = HTTPRequest.new()
	pass
	

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		SoundController.stop_music()
		return
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		SoundController.play_music()
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
	var date = OS.get_date()
	if date.year == 2023 and date.month == 4 and date.day < 22:
		return
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
		print("Loading Avatar: An error ", image_error ," occurred while trying to display the image.")
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
		language = language,
		userSelectedLanguage = userSelectedLanguage,
		soundOn = soundOn,
		musicOn = musicOn,
		tutorialDone = tutorialDone,
		eloRating = eloRating,
		maxEloRating = maxEloRating,
		playerLevel = playerLevel,
		winCount = winCount,
		tieCount = tieCount,
		firstTracksCount = firstTracksCount,
		achieveFirstBlood = achieveFirstBlood, # For first win
		achieveFirstFriend = achieveFirstFriend, # for first tie
		achievePioneer = achievePioneer, # for first 100 new seeds
		achieveIronStar = achieveIronStar, # for first 100 wins
		achieveSilverStar = achieveSilverStar, # for first 500 wins
		achieveGoldStar = achieveGoldStar, # for first 1000 wins
		achievePlatinumStar = achievePlatinumStar, # for first 5000 wins
		achieveNiobiumStar = achieveNiobiumStar,# for first 10000 wins
		achievePeaceMaker = achievePeaceMaker, # for first 100 ties
		characterModelName = characterModelName,
		firstRewardedSeed = firstRewardedSeed,
		secondRewardedSeed = secondRewardedSeed,
		thirdRewardedSeed = secondRewardedSeed

	}
	return to_json(save_dict)

func deserialize(gameData : String):
	if not gameData:
		return
	var data = parse_json(gameData)
	
	tutorialDone = data["tutorialDone"]
	language = data["language"]
	userSelectedLanguage = data["userSelectedLanguage"]
	soundOn = data["soundOn"]
	musicOn = data["musicOn"]
	tutorialDone = data["tutorialDone"]
	eloRating = data["eloRating"]
	maxEloRating = data["maxEloRating"]
	playerLevel = data["playerLevel"]
	winCount = data["winCount"]
	tieCount = data["tieCount"]
	firstTracksCount = data["firstTracksCount"]
	achieveFirstBlood = data["achieveFirstBlood"] # For first win
	achieveFirstFriend = data["achieveFirstFriend"] # for first tie
	achievePioneer = data["achievePioneer"] # for first 100 new seeds
	achieveIronStar = data["achieveIronStar"] # for first 100 wins
	achieveSilverStar = data["achieveSilverStar"] # for first 500 wins
	achieveGoldStar = data["achieveGoldStar"] # for first 1000 wins
	achievePlatinumStar = data["achievePlatinumStar"] # for first 5000 wins
	achieveNiobiumStar = data["achieveNiobiumStar"]# for first 10000 wins
	achievePeaceMaker = data["achievePeaceMaker"] # for first 100 tiespass
	characterModelName = data["characterModelName"]
	firstRewardedSeed = data["firstRewardedSeed"]
	secondRewardedSeed = data["secondRewardedSeed"]
	thirdRewardedSeed = data["secondRewardedSeed"]

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

