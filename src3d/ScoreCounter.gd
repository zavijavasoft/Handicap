extends Spatial

signal sig_picked_up(type, item)

export var value : int = 1

var label : Label3D

func pickup():
	#SoundController.play_sfx(SoundController.Sfx.BONUS)
	emit_signal("sig_picked_up", "counter", self)
	return value

func _ready():
	connect("sig_picked_up", get_parent(), "_on_Item_Picked_Up")
	label = get_node("Label3D")
	label.text = str(value)
	pass
