extends TrackBase

var actionList = []

func add_no_param_action(action, time):
	var chunk = {
		timestamp = time,
		action = action
	}
	
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
	
func die(time, reason):
	var chunk = {
		timestamp = time,
		action = ACTION_DIE,
		reason = reason
	}
	actionList.append(chunk)
	
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

func score_multiplier(time, value):
	var chunk = {
		timestamp = time,
		action = ACTION_MULTI,
		count = value
	}
	actionList.append(chunk)


func pickup_item(time, item):
	var chunk = {
		timestamp = time,
		action = ACTION_PICKUP_ITEM,
		item = item
	}
	actionList.append(chunk)


func reborn(time):
	add_no_param_action(ACTION_REBORN, time)

func respawn(time):
	add_no_param_action(ACTION_RESPAWN, time)

func get_track():
	return actionList
