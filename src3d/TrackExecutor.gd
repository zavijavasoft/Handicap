extends TrackBase

const Puppet = preload("res://Puppet.gd")

var foe : Puppet = null
var track = []
var cursor = 0
var allTime = 0

func start_execute(doll : Puppet, json_track: String = DEBUG_TRACK):
	foe = doll
	track = parse_json(json_track)
	pass

func fake_physics_process(delta):
	allTime += delta
	if cursor < track.size():
		var chunk = track[cursor]
		if chunk.timestamp < allTime:
			match chunk.action:
				ACTION_SCORE:
					foe.score(chunk.count)
				ACTION_MOVE_LEFT:
					foe.move_left()
				ACTION_MOVE_RIGHT:
					foe.move_right()
				ACTION_JUMP:
					foe.jump()
				ACTION_DIE:
					foe.die()
				ACTION_FINISH:
					foe.finish()
			cursor += 1
		
