extends Node

enum Data{

	join_queue,
	user_id,
	wait,
	lobby_id,
	match_data,

}

enum Modes{

	small,
	medium,
	large,
	custom,
	default,

}


var window = JavaScriptBridge.get_interface("window")
var peer = WebSocketMultiplayerPeer.new()
var user_id = 0
var lobby_id = 0

#get from database

var elo: int = 100 #default value

#gotten from javascript

var username: String = "guest"
var game_mode = Modes.default

var mine_number: int 
var grid_width: int 
var grid_height: int 


func _ready():

	game_mode = window.game_mode
	username = window.username
	get_board_dimensions_from_mode()



func initialise_game() -> void:
	var child_board = preload("res://scenes/minesweeper_board.tscn").instantiate()
	add_child(child_board)

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

			mine_number = window.mine_number
			grid_height = window.grid_height
			grid_width = window.grid_width
	


func _process(delta):

	peer.poll()
	
	#check for updated elo

	if peer.get_available_packet_count() > 0:

		var packet = peer.get_packet()

		if packet != null:

			var data = JSON.parse_string(packet.get_string_from_utf8())
			print(data)


func handle_data(data):

	match data:

		Data.user_id:

			user_id = data.id
			print("my id is " + str(user_id))
			join_matchmaking()

		Data.lobby_id:

			lobby_id = data.id

		Data.wait:
		
			pass


func join_matchmaking() -> void:

	var data = {

		"data_type" : Data.join_queue,
		"username" : "test",
		"elo" : elo

	}
	peer.put_packet(JSON.stringify(data).to_utf8_buffer())

func connect_to_server() -> void:

	peer.create_client("ws://127.0.0.1:8915")
	print("client_started")


	

func _on_start_client_button_down():
	
	connect_to_server()



func _on_send_test_packet_button_down():

	var message = {

		"data_type" : Data.join_queue,
		"data" : "test",

	}
	#print(message)
	var message_bytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(message_bytes)
