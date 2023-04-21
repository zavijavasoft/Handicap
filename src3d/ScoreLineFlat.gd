extends Control

const COLOR_RED = "#bf0a30"
const COLOR_BLUE = "003893"

onready var avatar = $Avatar

export var isFoe : bool = false 

export var heroName = "abracadabra"

func get_element_width():
	return $BkGnd.get_rect().size.x

func score(newValue):
	var stringValue
	if newValue > 99999:
		stringValue = str(newValue / 1000) + "k"
	elif newValue > 999999999:
		stringValue = str(newValue / 1000000) + "M"
	else:
		stringValue = str(newValue)
	$LabelScore.text = stringValue


func set_hero_name(newName):
	heroName = newName
	$LabelName.text = newName

func update_line():
	var avatarImage = G.avatarImage
	if isFoe:
		avatarImage = G.foeAvatarImage
	if avatarImage != null:
		var texture = ImageTexture.new()
		texture.create_from_image(avatarImage)
		var texSize = texture.get_size()
		avatar.texture = texture
		avatar.set_scale(Vector2(0.5, 0.5))

func _ready():
	update_line()
	
	if isFoe:
		$BkGnd.color = COLOR_RED
	else:
		$BkGnd.color = COLOR_BLUE

func _process(delta):
	pass
