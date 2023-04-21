extends Node


const FlatwaySc = preload("res://Flatway.tscn")
const HolewaySc = preload("res://Holeway.tscn")
const PikeSetSc = preload("res://PikeSet.tscn")
const GatesSc = preload("res://Gate.tscn")
const ScoreCounterSc = preload("res://Coin.tscn")
const ColumnSc = preload("res://Column.tscn")
const CachingRandomGenerator = preload("res://CachingRandomGenerator.gd")

const CONSONANTS = "BDEFGHJKLMNPRSTV"
const VOWELS = "AOEI"

var criticalMass = 0
var randomGenerator = CachingRandomGenerator.new()

func get_normal_dist_seq(count, mu, scale):
	var out = []
	out.resize(count + 1)
	var i = 0
	while i < count:
		var x = randomGenerator.randf() * 2 - 1
		var y = randomGenerator.randf() * 2 - 1
		var s = x * x + y * y
		if s == 0 or s > 1:
			continue
		var k = sqrt((-2 * log(s))/s)
		var sigma = sqrt(1)
		var z1 = k * x * sigma / (2 * PI) 
		var z2 = k * y * sigma / (2 * PI) 
		z1 = z1 / 2 
		z2 = z2 / 2 
		z1 = clamp(abs(ceil(z1 * scale) + mu), 1, scale)
		z2 = clamp(abs(ceil(z2 * scale) + mu), 1, scale)
		
		out[i] = z1
		out[i + 1] = z2
		i += 2
	out.resize(count)
	return out


func set_score_counter_factory(factory):
	pass
	
func _init(newSeed):
	randomGenerator.set_seed(newSeed)
	pass

func create_new_way_fragment(lastWay, finish):
	randomGenerator.update_cache()
	var fragmentType = randomGenerator.randi() % 100
	if fragmentType < 10 and not finish:
		return create_new_holeway_fragment(lastWay)
	
	return create_new_flatway_fragment(lastWay, finish)

func create_new_holeway_fragment(lastWay):
	var newWay = HolewaySc.instance()
	newWay.obstaclesMap = newWay.obstaclesMapForHoleway
	newWay.sequenceNumber = lastWay.sequenceNumber + 1
	newWay.translation = Vector3(0, 0, lastWay.translation.z + 20)
#	generate_obstacles(newWay)
	return newWay
	pass

func create_new_flatway_fragment(lastWay, finish):
	var newWay = FlatwaySc.instance()
	newWay.sequenceNumber = lastWay.sequenceNumber + 1
	newWay.translation = Vector3(0, 0, lastWay.translation.z + 20)
	newWay.override_material(randomGenerator.randi(), finish)
#	if not finish:
#		generate_obstacles(newWay)
	return newWay

func create_rotor_obstacle(way, i, j):
	var newPikeSet = PikeSetSc.instance()
	newPikeSet.translation.x = get_x_by_column(j)
	newPikeSet.translation.z = get_z_by_row(i)
	newPikeSet.rotate_y(PI / 2)
	way.add_child(newPikeSet)

func create_gates_obstacle(way, i, j, forced_op = -1, summa = -1):
	var deviation = randomGenerator.randi() % 10
	var value = clamp((way.sequenceNumber + deviation) * 10, 20, 999)
	var op = forced_op
	if forced_op < 0:
		op = Gate.get_by_random(randomGenerator.randi())
		if op in [2, 3]:
			value = value % 2 + 2
	else:
		value = summa
	var newGates = GatesSc.instance()
	newGates.apply_material(op, value)
	newGates.translation.x = get_x_by_column(j)
	newGates.translation.z = get_z_by_row(i)
	newGates.rotate_y(PI / 2)
	way.add_child(newGates)
	var check = newGates.change_score(criticalMass)
	if check > criticalMass:
		criticalMass = check
	

func create_column_obstacle(way, i, j):
	var newColumn = ColumnSc.instance()
	newColumn.translation.x = get_x_by_column(j)
	newColumn.translation.z = get_z_by_row(i)
	var rndRot = randomGenerator.randi() % 4
	var rndHeight = - randomGenerator.randf() * 4
	newColumn.translation.y = rndHeight
	newColumn.rotate_y(rndRot * PI/2)
	way.add_child(newColumn)

func try_setup_score_or_bonus(way, i, j, value):
	var chance = randomGenerator.randi() % 100 + 1
	if chance < 50:
		return 0
	if chance < 99:
		#var newCounter = scoreCounterFactory.create_score_counter(value)
		var newCounter = ScoreCounterSc.instance()
		var deviation_z = randomGenerator.randi() % 50 - 25
		var deviation_x = randomGenerator.randi() % 50 - 25
		newCounter.value = value
		newCounter.translation.x = get_x_by_column(j) + deviation_x / 100
		newCounter.translation.z = get_z_by_row(i) + deviation_z / 100
		newCounter.translate(Vector3(0, 1, 0))
		newCounter.rotate_y(PI)
		newCounter.rotate_z(PI)
		newCounter.scale = Vector3(0.5, 0.5, 0.5)
		way.add_child(newCounter)
		criticalMass += value
	pass

func generate_guillotine(wayFragment):
	var prohibited = false
	wayFragment.guillotinate_obstacle_map()
	var i = 4
	for j in range(3):
		if wayFragment.obstaclesMap[3 * i] in ["!", "-"]:
			return
	wayFragment.obstaclesMap[3 * i] = "!"
	wayFragment.obstaclesMap[3 * i + 1] = "!"
	wayFragment.obstaclesMap[3 * i + 2] = "!"
	var shift = randomGenerator.randi() % 3 
	var rnd = randomGenerator.randi() % 2 + 2
	var dist = [
		[0, 1, 2], [1, 0, 2], [1, 2, 0],
		[0, 2, 1], [2, 1, 0], [2, 0, 1]
		]
	
	var chance = dist[shift]
	create_column_obstacle(wayFragment, i, chance[0])
	create_gates_obstacle(wayFragment, i, chance[1], 3, rnd)
	var s = floor(criticalMass / (rnd * 10)) * 10
	create_gates_obstacle(wayFragment, i, chance[2], 1, s)
			
	criticalMass = 0
	pass
	
func generate_obstacles(wayFragment):
	if wayFragment.hasObstacles or wayFragment.isFinish:
		return
	var mu = wayFragment.sequenceNumber
	if mu < 2:
		return
	wayFragment.hasObstacles = true
	var idx = 0
	var rnd = get_normal_dist_seq(30, mu, 100)
	if mu % 5 == 0:
		if criticalMass > 1000:
			generate_guillotine(wayFragment)
	for i in range(10):
		for j in range(3):
			var setup = false
			while not setup:
				var mark = wayFragment.obstaclesMap[3 * i + j]
				if mark == "!":
					break
				if mark == "-":
					try_setup_score_or_bonus(wayFragment, i, j, rnd[idx])
					break
				var type = randomGenerator.randi() % 100
				if type < 3:
					create_rotor_obstacle(wayFragment, i, j)
					setup = true
				elif type < 6:
					create_gates_obstacle(wayFragment, i, j)
					setup = true
				elif type < 7:
					create_column_obstacle(wayFragment, i, j)
					setup = true
				elif type < 30:
					try_setup_score_or_bonus(wayFragment, i, j, rnd[idx])
					idx  +=  1
					setup = true
				else:
					setup = true

func get_x_by_column(column):
	match column:
		0:
			return 2
		2:
			return -2
	return 0

func get_z_by_row(row):
	return row * 2 - 9
	
