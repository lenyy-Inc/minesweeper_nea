extends Node

enum Data{

	join_queue,
	user_id,
	wait,
	lobby_id,
	match_data,
	demo,

}

enum Match_Data{

	win,
	loss,
	tile_uncovered,

}

enum Modes{

	small,
	medium,
	large,
	custom,
	default,

}

const ip := "127.0.0.1"
const port := "8915"

#var window = JavaScriptBridge.get_interface("window")
var peer = WebSocketMultiplayerPeer.new()
var time_elapsed : float = 0

#gotten from server
var player_number: int = -1
var user_id: int = 12
var lobby_id: int = 13

#get from database

var elo: int = 100 #default value

#gotten from javascript

var username: String = "guest"
var game_mode = Modes.default

var mine_coords:= []
var mine_number: int = 10
var grid_width: int = 10
var grid_height: int = 10

var demo_dict:= {}

signal end
signal win
signal lose
signal opponent_tile_uncovered
signal change_text

func _ready():

	#game_mode = window.game_mode
	#username = window.username

	get_window().size = Vector2i((64 * grid_height + 4), (64 * grid_width + 2))
	display_as_background_text("Attempting to connect to server...")
	initialise_game()
	game_end()
	display_as_background_text("game ended")
	

	pass

func display_as_background_text(text : String) -> void:
	change_text.emit(text)

func send_data_as_JSON(data) -> void:
	peer.put_packet(JSON.stringify(data).to_utf8_buffer())

func join_matchmaking() -> void:

	print("joining matchmaking")

	var join_matchmaking_request = {

		"id" : user_id,
		"data_type" : Data.join_queue,
		"username" : "test",
		"elo" : elo,
		"game_mode" : game_mode,

	}
	send_data_as_JSON(join_matchmaking_request)
	#peer.put_packet(JSON.stringify(join_matchmaking_request).to_utf8_buffer())

func send_win() -> void:

	var win_data = {

		"id" : user_id,
		"data_type" : Data.match_data,
		"match_data_type" : Match_Data.win,

	}
	send_data_as_JSON(win_data)


func send_loss() -> void:

	var loss_data = {

		"id" : user_id,
		"data_type" : Data.match_data,
		"match_data_type" : Match_Data.loss,

	}
	send_data_as_JSON(loss_data)

func send_tile_uncovered(number_uncovered) -> void:

	var tile_uncovered_update = {

		"id" : user_id,
		"data_type" : Data.match_data,
		"match_data_type" : Match_Data.tile_uncovered,
		"data" : number_uncovered,

	}
	send_data_as_JSON(tile_uncovered_update)


func write_demo(tile_position, is_left_click):

	var input

	match is_left_click:

		true:

			input = "left_click"

		_:

			input = "right_click"


	demo_dict[str(time_elapsed)] = {

		"tile" : tile_position,
		"input_type" : input,

	}

func initialise_game() -> void:

	get_board_dimensions_from_mode()
	var child_board = preload("res://scenes/minesweeper_tiled_board.tscn").instantiate()
	add_child(child_board)
	child_board.lose.connect(send_loss)
	child_board.win.connect(send_win)
	child_board.input.connect(write_demo)
	child_board.tile_uncovered.connect(send_tile_uncovered)

func get_board_dimensions_from_mode() -> void:

	match game_mode:

		Modes.small:

			mine_number = 10
			grid_height = 10
			grid_width = 10

		Modes.medium:

			mine_number = 40
			grid_height = 16
			grid_width = 16

		Modes.large:

			mine_number = 99
			grid_height = 16
			grid_width = 30

		Modes.custom:

			#mine_number = window.mine_number
			#grid_height = window.grid_height
			#grid_width = window.grid_width
			pass

		Modes.default:

			mine_number = 10
			grid_height = 10
			grid_width = 10


func _process(delta):

	peer.poll()
	
	#check for updated elo

	if peer.get_available_packet_count() > 0:

		var packet = peer.get_packet()

		if packet != null:

			var data = JSON.parse_string(packet.get_string_from_utf8())

			handle_data(data)


func handle_match_data(data):

	var data_type: int = data["match_data_type"]

	match data_type:

		Match_Data.win:

			game_end()
			pass_win()

		Match_Data.loss:
			
			game_end()
			pass_lose()

		Match_Data.tile_uncovered:

			var tile_number: int = data["data"]
			opponent_tile_uncovered.emit(tile_number)

		_:

			print("match_handler: nothing matched client")

func parse_mine_coords_string(string) -> void:

	var current_coords_x : String = ""
	var current_coords_y : String = ""
	var looking_at_x : bool = true

	for i in string.length:
		match string[i]:

			"|":

				looking_at_x = false
				pass
			
			"&":

				looking_at_x = true
				mine_coords.append(Vector2i(int(current_coords_x), int(current_coords_y)))

				current_coords_x = ""
				current_coords_y = ""

			_:

				if looking_at_x:
					current_coords_x += str(string[i])
				else:
					current_coords_x += str(string[i])

func handle_data(data):

	var data_type: int = data["data_type"]

	match data_type:

		Data.user_id:

			var int_id: int = data["id"]
			user_id = int_id
			print("my id is " + str(user_id))
			join_matchmaking()
			

		Data.lobby_id:

			var int_id: int = data["id"]
			lobby_id = int_id
			parse_mine_coords_string(data["mine_coords_string"])
			initialise_game()
			print("my lobby id is " + str(lobby_id) + " and user id is " + str(user_id))
			

		Data.wait:

			display_in_matchmaking(data["data"])

		Data.match_data:

			handle_match_data(data)

		_:

			print("data_handler: nothing matched client")

func display_in_matchmaking(time_elapsed) -> void:
	
	var text:= "Matchmaking for " + str(int(time_elapsed)) + " seconds..."
	change_text.emit(text)

func connect_to_server() -> void:

	peer.create_client("ws://" + ip + ":" + port)
	print("client_started")

func send_demo() -> void:

	var demo = {

		"id" : lobby_id,
		"data_type" : Data.demo,
		"data" : demo_dict,

	}

	send_data_as_JSON(demo_dict)

func game_end() -> void:
	end.emit()

func pass_win() -> void:
	win.emit()

func pass_lose() -> void:
	lose.emit()
	get_tree().paused = true

func _on_start_client_button_down():
	
	connect_to_server()

func _on_send_test_packet_button_down():

	var message = {

		"data_type" : Data.join_queue,
		"data" : "test",

	}
	#print(message)
	send_data_as_JSON(message)
	#var message_bytes = JSON.stringify(message).to_utf8_buffer()
	#peer.put_packet(message_bytes)
