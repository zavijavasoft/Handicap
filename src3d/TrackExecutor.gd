extends TrackBase

const Puppet = preload("res://Puppet.gd")

var foe : Puppet = null
var track = []
var cursor = 0
var allTime = 0

func start_execute(doll : Puppet, json_track: String):
	allTime = 0
	foe = doll
	if json_track.empty():
		json_track = DEBUG_TRACK
	track = parse_json(json_track)
	pass

func fake_physics_process(delta):
	allTime += delta
	if cursor < track.size():
		var chunk = track[cursor]
		if chunk.timestamp < allTime:
			print("Action: ", chunk.action)
			match chunk.action:
				ACTION_SCORE:
					foe.score(chunk.count)
				ACTION_MULTI:
					foe.score_multiplier(chunk.count)
				ACTION_MOVE_LEFT:
					foe.move_left()
				ACTION_MOVE_RIGHT:
					foe.move_right()
				ACTION_JUMP:
					foe.jump()
				ACTION_DIE:
					foe.die(chunk.reason)
				ACTION_REBORN:
					foe.reborn()
				ACTION_RESPAWN:
					foe.respawn()
				ACTION_FINISH:
					foe.finish()
				ACTION_PICKUP_ITEM:
					foe.pickup_item(chunk.item)
			cursor += 1
		
