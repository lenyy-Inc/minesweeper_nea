extends Sprite2D

var time_elapsed: float

signal digit_1
signal digit_2
signal digit_3

func _ready():
	#position = get_parent().childposition
	#get_parent().lose.connect(lose)
	pass

func lose() -> void:
	digit_1.emit("lose")
	digit_2.emit("lose")
	digit_3.emit("lose")


func _process(delta):

	time_elapsed += delta
	var digits:= [0, 0, 0]
	var count = 2
	var stringdigits:= str(int(time_elapsed))
	for i in stringdigits:
		
	for i in digits:
		print(i)
	digit_1.emit(digits[0])
	digit_2.emit(digits[1])
	digit_3.emit(digits[2])
