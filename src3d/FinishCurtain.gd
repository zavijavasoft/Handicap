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
			$ResultLabel.text = tr("tie")
			$RestartButton/RestartLabel.text = tr("restart_track")
			pass
		CurtainMode.DEFEAT:
			$ResultLabel.text = tr("loose")
			$RestartButton/RestartLabel.text = tr("take_revenge")
			pass
	$ChangeFoeButton/ChangeFoeLabel.text = tr("change_foe")
	$NextTrackButton/NextTrackLabel.text = tr("next_route")
	$ExitButton/ExitLabel.text = tr("exit_track")

func _on_RestartButton_pressed():
	G.switch_to_main_scene()


func _on_ChangeFoeButton_pressed():
	G.reach_goal("change_foe_clicked")
	NetManager.findTrack(G.currentSeed)
	G.lastRating = -1
	var date = OS.get_date()
	if date.year == 2023 and date.month == 4 and date.day >21 and mode == CurtainMode.WON:
		AdvManager.showFullscreenAdv(self, "_on_after_not_exit_button")
	else:
		G.switch_to_main_scene()


func _on_NextTrackButton_pressed():
	G.reach_goal("change_track_clicked")
	NetManager.findTrack()
	G.lastRating = -1
	var date = OS.get_date()
	if date.year == 2023 and date.month == 4 and date.day >21 and mode == CurtainMode.WON:
		AdvManager.showFullscreenAdv(self, "_on_after_not_exit_button")
	else:
		G.switch_to_main_scene()


func _on_ExitButton_pressed():
	G.reach_goal("leave_race_clicked")
	G.lastRating = -1
	var date = OS.get_date()
	if date.year == 2023 and date.month == 4 and date.day >21 and mode == CurtainMode.WON:
		AdvManager.showFullscreenAdv(self, "_on_after_exit_button")
	else:
		G.switch_to_start_scene()

func _on_after_exit_button():
	G.switch_to_start_scene()

func _on_after_not_exit_button():
	G.switch_to_main_scene()
	
