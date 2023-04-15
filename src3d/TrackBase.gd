extends Node
class_name TrackBase

const ACTION_MOVE_LEFT = "move_left"
const ACTION_MOVE_RIGHT = "move_right"
const ACTION_JUMP = "jump"
const ACTION_DIE = "die"
const ACTION_FINISH = "finish"
const ACTION_SCORE = "score"
const ACTION_MULTI = "multi"
const ACTION_REBORN = "reborn"
const ACTION_RESPAWN = "respawn"
const ACTION_PICKUP_ITEM = "pickup_item"

const DEBUG_TRACK = """
[
{
	"action": "move_left",
	"timestamp": 10,
},
{
	"action": "jump",
	"timestamp": 12,
},
{
	"action": "move_right",
	"timestamp": 14,
}
]
"""

func _ready():
	pass
