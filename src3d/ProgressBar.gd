extends Control

const FULL_WIDTH = 1024

export var wayPart : float = 0.0

func _ready():
	set_progress()
	pass

func set_progress():
	var passedLen = wayPart * FULL_WIDTH
	var lastLen = FULL_WIDTH - passedLen
	$Marker.position.x = passedLen
	$PassedRect.set_size(Vector2(passedLen, 40))
	$ToGoRect.set_size(Vector2(lastLen + 40, 40))
	$ToGoRect.set_position(Vector2(FULL_WIDTH - lastLen, 0))
	pass

func update_progress(part):
	wayPart = part
	set_progress()
