extends Node

const CACHE_SIZE = 500

var generator = RandomNumberGenerator.new()

var cachei = []
var cachef = []
var cursori = 0
var cursorf = 0

func _init():
	cachei.resize(CACHE_SIZE)
	cachef.resize(CACHE_SIZE)
	update_cache()

func set_seed(seed_):
	generator.seed = seed_
	

func randi():
	var value = cachei[cursori]
	cursori = (cursori + 1) % CACHE_SIZE
	return value

func randf():
	var value = cachef[cursorf]
	cursorf = (cursorf + 1) % CACHE_SIZE
	return value


func update_cache():
	cursori = 0
	cursorf = 0
	for i in range(CACHE_SIZE):
		cachei[i] = generator.randi()
		cachef[i] = generator.randf()
	pass
