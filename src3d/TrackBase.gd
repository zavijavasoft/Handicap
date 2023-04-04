extends Node
class_name TrackBase

const ACTION_MOVE_LEFT = "move_left"
const ACTION_MOVE_RIGHT = "move_right"
const ACTION_JUMP = "jump"
const ACTION_DIE = "die"
const ACTION_FINISH = "finish"
const ACTION_SCORE = "score"

const DEBUG_TRACK = """
[
{
	"action": "move_left",
	"timestamp": 30,
},
{
	"action": "jump",
	"timestamp": 32,
},
{
	"action": "move_right",
	"timestamp": 34,
}
]
"""

func _ready():
	pass
