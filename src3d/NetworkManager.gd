extends Node

const URI = "https://d5dacjq1nvqppjn8renv.apigw.yandexcloud.net/track"
const GET_REQUEST_FORMAT = URI + "?user_id=%s&app_id=%s&rating=%d"

var trackFinder : HTTPRequest
var trackUploader : HTTPRequest

func _init():
	trackFinder = HTTPRequest.new()
	trackUploader = HTTPRequest.new()

func _ready():
	add_child(trackFinder)
	add_child(trackUploader)
	trackFinder.connect("request_completed", self, "_on_FindTrack_request_completed")
	trackUploader.connect("request_completed", self, "_on_TrackUpload_request_completed")
	pass


func findTrack(seed_ = 0):
	G.trackLoadingPending = true
	var id = G.get_user_unique_id()
	var appId = G.AppID.percent_encode()
	var seedPart = ""
	if seed_ != 0:
		seedPart = "&seed=" + str(seed_)
	var request = GET_REQUEST_FORMAT % [id, appId, G.eloRating]
	print("Track request ", request)
	trackFinder.request(request)
	pass
	
func uploadTrack(rating, seed_, mode, track):
	var avatarString = ""
	if G.avatarImage != null:
		avatarString = Marshalls.raw_to_base64(G.avatarImage)
	var message = {
		user_id = G.get_user_unique_id(),
		user_name = G.userName,
		rating = rating,
		mode = mode,
		app_id = G.AppID,
		seed = G.currentSeed,
		track = track,
		avatar = avatarString
	}
	var query = JSON.print(message)
	print(message)
	var headers = ["Content-Type: application/json"]
	trackUploader.request(URI, headers, true, HTTPClient.METHOD_POST, query)
	pass


func _on_FindTrack_request_completed(result, response_code, headers, body):
	var bodyString = body.get_string_from_utf8()
	var jsonResult = JSON.parse(bodyString)
	if jsonResult.error == OK and jsonResult.result.has("user_name"):
		var json = jsonResult.result
		G.foeName = json["user_name"]
		G.foeTrack = json["track"]
		G.currentSeed = json["seed"]
		G.foeRating = json["rating"]
		var avatarString = json["avatar"]
		if not avatarString.empty():
			G.foeAvatarImage = Image.new()
			var avatarData = Marshalls.base64_to_raw(avatarString)
			var imageError = G.foeAvatarImage.load_jpg_from_buffer(avatarData)
			if imageError != OK:
				G.foeAvatarImage = null
				print("An error occurred while trying to display the foe avatar.")
	else:
		G.foeTrack = ""
	G.trackLoadingPending = false
	pass

func _on_TrackUpload_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Upload track error", body.get_string_from_utf8())
	pass
