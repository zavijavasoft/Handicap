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

func set_multiplier(newValue):
	var stringValue
	if newValue > 999:
		stringValue = str(newValue / 1000) + "k"
	elif newValue > 9999999:
		stringValue = str(newValue / 1000000) + "M"
	else:
		stringValue = str(newValue)
	$LabelMultiplier.text = "x" + stringValue


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
	score(0)
	set_multiplier(1)
	update()
	
	if isFoe:
		$BkGnd.color = COLOR_RED
		$LabelName.set_position(Vector2(280, 15))
		$LabelScore.set_position(Vector2(280, 50))
		$LabelMultiplier.set_position(Vector2(220, 110))
		$Avatar.set_position(Vector2(120, 40))
		$Avamask.set_position(Vector2(120, 90))
	else:
		$BkGnd.color = COLOR_BLUE
		$LabelName.set_position(Vector2(20, 15))
		$LabelScore.set_position(Vector2(20, 50))
		$LabelMultiplier.set_position(Vector2(30, 110))
		$Avatar.set_position(Vector2(380, 40))
		$Avamask.set_position(Vector2(380, 90))
	update()
	pass

func _process(delta):
	pass
