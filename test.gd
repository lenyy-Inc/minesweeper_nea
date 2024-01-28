extends Node

var testdict:= {}
var time_passed = 0

# Called when the node enters the scene tree for the first time.
func _ready():

	for i in range(0,10):
		testdict[i] = i

	var testarray:= []

	testarray = testdict.keys()

	for thing in testarray:
		print(thing)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for item in testdict:
		testdict[item] += delta
	
	time_passed += delta
	if time_passed > 10 and time_passed < 10.2:
		for item in testdict:
			print(testdict[item])

	
