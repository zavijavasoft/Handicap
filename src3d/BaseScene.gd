extends Container
class_name BaseScene

var minWindowHeight = 960
var minWinwowWidth = 512

var prevViewportSize = Vector2.ZERO
var viewportSize = Vector2.ZERO

func _ready():
	viewportSize = get_viewport_rect()
	prevViewportSize = viewportSize
	get_node("/root").connect("size_changed", self, "_on_resize")
	pass

func _on_resize():
	var currentSize = OS.get_window_size()

	if(currentSize.x < minWinwowWidth):
		OS.set_window_size(Vector2(minWinwowWidth, currentSize.y))

	if(currentSize.y < minWindowHeight):
		OS.set_window_size(Vector2(currentSize.x, minWindowHeight))

func update_viewport_size():
	var newViewportSize = get_viewport_rect()
	if (newViewportSize.size.x != viewportSize.size.x
			or newViewportSize.size.y != viewportSize.size.y):
				prevViewportSize = viewportSize
				viewportSize = newViewportSize
				_on_Layout_Update()

func _on_Layout_Update():
	pass

func _on_ButtonSound_toggled(button_pressed):
	SoundController.on_sound_button_pressed(button_pressed)
