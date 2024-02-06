extends Sprite2D

var score: int

signal digit_1
signal digit_2
signal digit_3

const child_colour:= Color(0,0,10)

func _ready():
	position = get_parent().opponent_score_position_offset
	get_parent().lose.connect(loss_received)
	get_parent().opponent_tile_uncovered.connect(update_player_score)

func update_player_score():

	score += 1

	var stringdigits:= str(score)
	var digits:= [0, 0, 0]
	var count = 0

	for i in range(stringdigits.length() - 1, -1, -1):
		digits[count] = stringdigits[i]
		count += 1

	digit_1.emit(digits[0])
	digit_2.emit(digits[1])
	digit_3.emit(digits[2])


func loss_received() -> void:
	digit_1.emit("lose")
	digit_2.emit("lose")
	digit_3.emit("lose")

