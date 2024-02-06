extends Sprite2D

var time_elapsed: float = 990
var lose_emitted: bool

signal digit_1
signal digit_2
signal digit_3
signal lose

const child_colour:= Color(10,0,0)

func _ready():
	position = get_parent().timer_position_offset
	get_parent().lose.connect(loss_received)
	pass

func loss_received() -> void:
	digit_1.emit("lose")
	digit_2.emit("lose")
	digit_3.emit("lose")


func _process(delta):

	time_elapsed += delta

	if time_elapsed >= 999:
		if !lose_emitted:
			lose.emit()
			lose_emitted = true
		return

	var digits:= [0, 0, 0]
	var count = 0
	var stringdigits:= str(int(time_elapsed))

	for i in range(stringdigits.length() - 1, -1, -1):
		digits[count] = stringdigits[i]
		count += 1

	digit_1.emit(digits[0])
	digit_2.emit(digits[1])
	digit_3.emit(digits[2])
