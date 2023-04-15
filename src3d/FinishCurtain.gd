extends Control



enum CurtainMode {
	WON,
	TIE,
	DEFEAT
}

var title = ""
var mode = CurtainMode.WON

func _ready():
	pass

func show_in_mode(mode_):
	mode = mode_
	update_locale()
	show()
	
func update_locale():
	match mode:
		CurtainMode.WON:
			$ResultLabel.text = tr("win")
			$RestartButton/RestartLabel.text = tr("restart_track")
			pass
		CurtainMode.TIE:
			$ResultLabel.text = tr("loose")
			$RestartButton/RestartLabel.text = tr("restart_track")
			pass
		CurtainMode.DEFEAT:
			$ResultLabel.text = tr("tie")
			$RestartButton/RestartLabel.text = tr("take_revenge")
			pass
	$ChangeFoeButton/ChangeFoeLabel.text = tr("change_foe")
	$NextTrackButton/NextTrackLabel.text = tr("next_route")
	$ExitButton/ExitLabel.text = tr("exit_track")

func _on_RestartButton_pressed():
	G.switch_to_main_scene()


func _on_ChangeFoeButton_pressed():
	NetManager.findTrack(G.currentSeed)
	G.switch_to_main_scene()


func _on_NextTrackButton_pressed():
	NetManager.findTrack()
	G.switch_to_main_scene()


func _on_ExitButton_pressed():
	G.switch_to_start_scene()
