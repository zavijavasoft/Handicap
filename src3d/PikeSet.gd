extends Spatial

onready var player = $AnimationPlayer

var fixed = false

func _ready():
	pass

func _on_PikeSetArea_area_entered(area):
	if fixed:
		return
	if area.name == "AreaHero":
		player.play("Cyl5Up")
		fixed = true
