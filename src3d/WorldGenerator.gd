extends Node

const FlatwaySc = preload("res://Flatway.tscn")


func set_seed(newSeed):
	rand_seed(newSeed)

func _ready():
	pass

func create_new_way_fragment(lastWay):
	var fragmentType = randi() % 100
	
	
	return create_new_flatway_fragment(lastWay)

func create_new_flatway_fragment(lastWay):
	var newWay = FlatwaySc.instance()
	newWay.translation = Vector3(0, 0, lastWay.translation.z + 20)
	newWay.override_material(randi())
	return newWay
	
