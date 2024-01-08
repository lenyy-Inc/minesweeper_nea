extends Sprite2D

const sprite_blank = preload("res://textures/beta/number_display/num_blank.png")
const sprite_zero = preload("res://textures/beta/number_display/num_zero.png")
const sprite_one = preload("res://textures/beta/number_display/num_one.png")
const sprite_two = preload("res://textures/beta/number_display/num_two.png")
const sprite_three = preload("res://textures/beta/number_display/num_three.png")
const sprite_four = preload("res://textures/beta/number_display/num_four.png")
const sprite_five = preload("res://textures/beta/number_display/num_five.png")
const sprite_six = preload("res://textures/beta/number_display/num_six.png")
const sprite_seven = preload("res://textures/beta/number_display/num_seven.png")
const sprite_eight = preload("res://textures/beta/number_display/num_eight.png")
const sprite_nine = preload("res://textures/beta/number_display/num_nine.png")
const sprite_eye = preload("res://textures/beta/number_display/num_eye.png")
const sprite_mouth = preload("res://textures/beta/number_display/num_mouth.png")

func _ready():

	position = Vector2i(-32, 0)
	get_parent().digit_3.connect(change_texture)


func change_texture(digit) -> void:
	print(digit)
	match digit:
		0:
			texture = sprite_zero
		1:
			texture = sprite_one
		2:
			texture = sprite_two
		3:
			texture = sprite_three
		4:
			texture = sprite_four
		5:
			texture = sprite_five
		6:
			texture = sprite_six
		7:
			texture = sprite_seven
		8:
			texture = sprite_eight
		9:
			texture = sprite_nine
		"lose":
			texture = sprite_eye
