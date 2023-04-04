extends Spatial

onready var mesh = $Cube

var zebra_material = null

func override_material(rand_value):
	var index = rand_value % 10
	match index:
		0, 1, 2:
			if (zebra_material == null):
				zebra_material = load("res://models/way_fragments/Material_Flatway_Zebra.material")
	pass

func _ready():
	if zebra_material != null:
		mesh.material_override = zebra_material
	pass
