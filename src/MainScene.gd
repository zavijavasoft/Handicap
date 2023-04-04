extends Node2D

const RoadFragmentSc = preload("res://RoadFragment.tscn")

const SCALE_ROAD = 2.2
const BASE_Y_ROAD = 1200
const SCALE_Y_ROAD = 212

enum SceneState {
	STARTING,
	RUNNING,
	PAUSED,
	FINISHED
}

var sceneState = SceneState.STARTING
var timeCount : float = 0.0

var roadFragmentsCount = 0
var roadFragments = []

func _ready():
	rand_seed(100)
	for i in range(10):
		var fragment = create_road_fragment(roadFragmentsCount)
		var internalIndex = (10 - i - 2)
		var scaleIndex = pow(SCALE_ROAD, -internalIndex)
		fragment.scale = Vector2(scaleIndex, scaleIndex)
		fragment.position = Vector2(512 * (1 - scaleIndex), BASE_Y_ROAD * scaleIndex - scaleIndex * SCALE_Y_ROAD)
		roadFragments.append(fragment)
		add_child(fragment)
	pass


func _physics_process(delta):
	match sceneState:
		SceneState.STARTING:
			pass
		SceneState.FINISHED:
			pass
		SceneState.PAUSED:
			pass
		SceneState.RUNNING:
			timeCount += delta
			handleRunning()
pass


func handleRunning():
	
	pass


static func create_road_fragment(roadFragmentCounter: int):
	var fragment = RoadFragmentSc.instance()
	return fragment
