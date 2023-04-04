extends Spatial

onready var player = $AnimationPlayer

func _ready():
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	player.play("Armature002|mixamocom|Layer0")
	pass # Replace with function body.
