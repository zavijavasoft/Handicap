extends Node

const Ops = [
	"plus", # +
	"minus",
	"mult", # +
	"div",
]

func get_text_by_operation(operation : String, argument):
	if operation.begins_with("plus"):
		return "+" + str(argument)
	if operation.begins_with("minus"):
		return "-" + str(argument)
	if operation.begins_with("mult"):
		return "x" + str(argument)
	if operation.begins_with("div"):
		return "/" + str(argument)
	return ""


func evaluate(op, arg1, arg2):
	return call(op, arg1, arg2)

func plus(x, y):
	return x + y

func minus(x, y):
	return clamp(x - y, 0, x)

func mult(x, y):
	return x * y
	
func div(x, y):
	return ceil(x / y)
	
func sqrt_x(x):
	return ceil(sqrt(x))	
	
func sqr_x(x):
	return x * x
