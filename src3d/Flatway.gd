extends Spatial

onready var mesh = $Cube
onready var finishArea = $FinishArea 

export var sequenceNumber : int = 0

var overriding_material = null
var isFinish = false

var previousObstacleMask = ""
var obstaclesMap = "*>+*>+*>+*>+*>+*>+*>+*>+*>+*>+"
# * -- можно ставить во все 3 полосы
# > -- можно ставить в 2 полосы, 3-я занята
# + -- можно ставить в конкретную точку
# ! -- нельзя ставить ничего
# - -- можно ставить скоры и бонусы, нельзя ставить препятствия
var obstaclesMapForHoleway = "*>+*>+*>+*>+*>+------*>+*>+*>+"

func merge_previous_obstacle_map():
	if previousObstacleMask.length() > obstaclesMap.length():
		previousObstacleMask = previousObstacleMask.left(obstaclesMap.length())
	for c in range(previousObstacleMask.length()):
		obstaclesMap[c] = previousObstacleMask[c]

func guillotinate_obstacle_map():
	previousObstacleMask = "------------"
	merge_previous_obstacle_map()
	pass

func override_material(rand_value, finish):
	var index = rand_value % 10
	isFinish = finish
	match index:
		0, 1, 2:
			overriding_material = load("res://models/way_fragments/Material_Flatway_Zebra.material")
	if finish:
			overriding_material = load("res://models/way_fragments/Material_Flatway_Finish.material")
	pass

func _ready():
	if overriding_material != null:
		mesh.material_override = overriding_material
	finishArea.monitorable = isFinish

func _on_Item_Picked_Up(type, sender):
	remove_child(sender)
