extends TrackBase

var actionList = []

func add_no_param_action(action, time):
	var chunk = {
		timestamp = time,
		action = action
	}
	print("Action: ", chunk)
	actionList.append(chunk)

func move_left(time):
	add_no_param_action(ACTION_MOVE_LEFT, time)
	pass
	
func move_right(time):
	add_no_param_action(ACTION_MOVE_RIGHT, time)
	pass
	
func jump(time):
	add_no_param_action(ACTION_JUMP, time)
	pass
	
func die(time):
	add_no_param_action(ACTION_DIE, time)
	pass
	
func finish(time):
	add_no_param_action(ACTION_FINISH, time)
	pass
	
func score(time, value):
	var chunk = {
		timestamp = time,
		action = ACTION_SCORE,
		count = value
	}
	actionList.append(chunk)

func get_track():
	return to_json(actionList)
