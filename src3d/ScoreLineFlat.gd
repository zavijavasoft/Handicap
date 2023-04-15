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

func update():
	if G.avatarImage != null:
		var texture = ImageTexture.new()
		texture.create_from_image(G.avatarImage)
		var texSize = texture.get_size()
		var xRatio = 240 / texSize.x
		var yRatio = 240 / texSize.y
		print("Tex size: ", texSize, " ratios: ", Vector2(xRatio , yRatio))
		avatar.texture = texture
		avatar.set_scale(Vector2(xRatio, yRatio))

func _ready():
	update()
	
	if isFoe:
		$BkGnd.color = COLOR_RED
	else:
		$BkGnd.color = COLOR_BLUE

func _process(delta):
	pass
