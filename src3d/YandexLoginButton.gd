extends Control

onready var avatar = $Auth/Avatar

func _ready():
	pass

func update_control():
	$NoAuth.hide()
	$Auth.hide()
	
	if G.userLoggedIn:
		$Auth/LoginName.text = G.userName
		$Auth.show()
		if G.avatarImage != null:
			var texture = ImageTexture.new()
			texture.create_from_image(G.avatarImage)
			avatar.texture = texture
			avatar.set_scale(Vector2(0.5, 0.5))
	else:
		$NoAuth.show()
		$NoAuth/YaButton/Label.text = tr("ya_invitation")


func _on_YaButton_pressed():
	G.reach_goal("login_pressed")
	G.platformApi.authorize()
	pass # Replace with function body.
