extends Spatial
class_name Gate

signal sig_gate_picked_up(type, item)

const RedMat = preload("res://models/obstacles/Gates/GatesRed.material")
const BlueMat = preload("res://models/obstacles/Gates/GatesBlue.material")

const GateOperations = preload("res://GateOperations.gd")


onready var mesh = $Cylinder002
onready var label3D = $Cylinder002/Label3D


export var operation : String = ""
var opIndex : int = 0
var argument : int = 0
var operator = GateOperations.new()
var isEinstein = false


static func get_by_random(rnd :int):
	rnd %= 100
	if (rnd < 5):
		return 3
	if (rnd < 10):
		return 2
	if (rnd < 55):
		return 1
	return 0

func change_score(score):
	return operator.evaluate(operation, score, argument)

func apply_material(op, value):
	opIndex = op
	argument = value
	operation = GateOperations.Ops[op]
	pass
	
func update_gate():
	
	var plus = true
	
		
	if opIndex % 2 > 0:
		plus = false
		mesh.material_override = RedMat
	else:
		mesh.material_override = BlueMat
	
	var text = operator.get_text_by_operation(operation, argument)
	
	label3D.text = text
		
func pickup():
	SoundController.play_sfx(SoundController.Sfx.GATE)
	$Cylinder002.hide()
	
func _ready():

	update_gate()

