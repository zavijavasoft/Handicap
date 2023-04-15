extends Node

signal sig_swiped(direction)

export (int, 100, 500) var SWIPE_LENGTH = 150
export (float, 1.0, 1.5) var MAX_DIAGONAL_SLOPE = 1.3


onready var timer = $Timer
var swipeStartPosition = Vector2()

func _input(event):
	if not event is InputEventScreenTouch:
		return
	if event.is_pressed():
		start_detection(event.position)
	elif not timer.is_stopped():
		end_detection(event.position)
	pass

func start_detection(position):
	swipeStartPosition = position
	timer.start()
	pass
	
func end_detection(position):
	timer.stop()
	var direction = (position - swipeStartPosition)
	if (direction.length_squared() >= SWIPE_LENGTH * SWIPE_LENGTH):
		var dnormed = direction.normalized()
		if abs(dnormed.x) > abs(dnormed.y):
			if dnormed.x > 0:
				emit_signal("sig_swiped", 1)
			else:
				emit_signal("sig_swiped", -1)
		else:
			if dnormed.y < 0:
				emit_signal("sig_swiped", 0)
	#else:
		#emit_signal("sig_swiped", 0)

func _ready():
	pass


func _on_Timer_timeout():
	print("timeout...")
	timer.stop()
