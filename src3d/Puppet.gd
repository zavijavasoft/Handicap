extends Spatial
class_name Puppet, "res://icon.png"

enum RunnerMode {
	SINGLE,
	HERO,
	FOE
}

const HERO_X_POS = -0.5
const FOE_X_POS = 0.5
const SINGLE_X_POS = 0


var sideVelocity = 8.0

func move_left():
	pass
	
func move_right():
	pass
	
func jump():
	pass
	
func die():
	pass
	
func finish():
	pass
	
func score(value: int):
	pass
