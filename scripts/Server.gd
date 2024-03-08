extends Node

enum Data{

	join_queue,
	user_id,
	wait,
	lobby_id,
	match_data,

}


enum Match_Data{

	win,
	loss,
	tile_uncovered,

}

var lobbies:= {}
var users:= {}
var matchmaking:= {}
var peer = WebSocketMultiplayerPeer.new()

func place_mines(grid_height, grid_width, mine_number) -> Array:

	var grid:= []
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append(Vector2i(i, j))

	var mine_coords:= []
	var x: int
	var y: int 	
	for i in mine_number:
		
		x = randi_range(0, grid_width - 1)
		y= randi_range(0, grid_height - 1)
		
		while mine_coords.has(grid[x][y]):
			x = randi_range(0, grid_width - 1)
			y = randi_range(0, grid_height - 1)

	return mine_coords

func _ready():
	peer.peer_connected.connect(peer_connected)
	peer.peer_disconnected.connect(peer_disconnected)

func _process(delta):

	peer.poll()

	if peer.get_available_packet_count() > 0:

		var packet = peer.get_packet()

		if packet != null:

			var data = JSON.parse_string(packet.get_string_from_utf8())
			handle_data(data)
	
	
	if matchmaking.size() >= 2:
		matchmake()
		

	var ids:= matchmaking.keys()
	for id in ids:
		
		matchmaking[id]["time_waited"] += delta

		var wait_message = {

			"data_type" : Data.wait,
			"data" : matchmaking[id]["time_waited"],

		}
	
		send_data_as_JSON(id, wait_message)
		#peer.get_peer(id).put_packet((JSON.stringify(wait_message).to_utf8_buffer()))

func handle_win(winner_id):
	
	var loss_message:= {

		"data_type" : Data.match_data,
		"match_data_type" : Match_Data.loss,

	}

	send_to_other_in_lobby(winner_id, loss_message)

func handle_loss(loser_id):

	var win_message:= {

	"data_type" : Data.match_data,
	"match_data_type" : Match_Data.win,

	}

	send_to_other_in_lobby(loser_id, win_message)

func send_updated_tile_uncovered(sender_id, tile_number):

	var update_opponent_tile_number:= {

		"data_type" : Data.match_data,
		"match_data_type" : Match_Data.tile_uncovered,
		"data" : tile_number,

	}

	send_to_other_in_lobby(sender_id, update_opponent_tile_number)

func handle_match_data(data):

	var data_type: int = data["match_data_type"]


	match data_type:

		Match_Data.win:

			var int_id: int = data["id"]
			handle_win(int_id)

		Match_Data.loss:

			var int_id: int = data["id"]
			handle_loss(int_id)

		Match_Data.tile_uncovered:

			var int_id: int = data["id"]
			var tile_number: int = data["data"]
			send_updated_tile_uncovered(int_id, tile_number)

		_:

			print("match_handler: nothing matched server")

func add_player_to_queue(data):

	var int_elo: int = data["elo"]
	var int_id: int = data["id"]

	print("placed into matchmaking")
	matchmaking[int_id] = {

	"id" : int_id,
	"elo" : int_elo,
	"current_opponent" : null,
	"current_elo_gap" : null,
	"time_waited" : 0,

	}

	var extra_user_data = {

	"username" : data.username,
	"elo" : int_elo,

	}

	print(users[int_id])

	users[int_id].merge(extra_user_data)


func handle_data(data):

	print("server handling")

	var data_type: int = data["data_type"]
	var int_id: int = data["id"]
	var int_elo: int 

	#take out everythitn within the match statement into their own functions
	#finish making networking work, in preparation for an actual test so that database stuff can begin to be incorporated

	match data_type:

		Data.join_queue:

			add_player_to_queue(data)

		Data.match_data:

			handle_match_data(data)

		_:

			print("nothing matched server")


func is_better_match(candidate_1, candidate_2, elo_difference) -> bool:

	if not candidate_1["current_elo_gap"] == null:
		if candidate_1["current_elo_gap"] <= elo_difference:
			return false

	if not candidate_2["current_elo_gap"] == null:
		if candidate_2["current_elo_gap"] <= elo_difference:
			return false

	return true

func matchmake() -> void:


	var in_matchmaking:= []
	var match_conditions: bool 
	var difference_lenience: int
	var elo_difference: int

	in_matchmaking = matchmaking.keys()

	for i in range(0, in_matchmaking.size() - 1):
		for j in range(i + 1, in_matchmaking.size()):


			var candidate_1 = matchmaking[in_matchmaking[i]]

			var candidate_2 = matchmaking[in_matchmaking[j]]


			elo_difference = candidate_1["elo"] - candidate_2["elo"]
			difference_lenience = 5 * (candidate_1["time_waited"] + 1) * (candidate_2["time_waited"] + 1)
			if difference_lenience > 100:
				difference_lenience = 100
			match_conditions = elo_difference <= difference_lenience

			if match_conditions and is_better_match(candidate_1, candidate_2, elo_difference):
				
				candidate_1["current_opponent"] = candidate_2["id"]
				candidate_2["current_opponent"] = candidate_1["id"]
				candidate_1["current_elo_gap"] = elo_difference
				candidate_2["current_elo_gap"] = elo_difference
		
	for key in in_matchmaking:

		if not matchmaking.has(key):
			continue

		var user = matchmaking[key]

		if (user["current_opponent"] == null):
			continue

		if not matchmaking.has(user["current_opponent"]):
			user["current_opponent"] = null
			continue

		var user_chosen_opponent = matchmaking[user["current_opponent"]]

		if user["id"] == user_chosen_opponent["current_opponent"]:

			create_new_lobby(user["id"], user_chosen_opponent["id"])



func create_new_lobby(player_1_id, player_2_id) -> void:

	var new_lobby_id: int = generate_random_id()
	var player_1 = users[player_1_id]
	var player_2 = users[player_2_id]

	lobbies[new_lobby_id] = {

		"id" : new_lobby_id,
		"player_1" : player_1["id"],
		"player_2" : player_2["id"],

	}

	player_1["lobby"] = new_lobby_id 
	player_2["lobby"] = new_lobby_id 

	print("new lobby id: " + str(new_lobby_id))

	var send_lobby = {

		"data_type" : Data.lobby_id,
		"id" : new_lobby_id,

	}

	send_data_as_JSON(player_1["id"], send_lobby)
	send_data_as_JSON(player_2["id"], send_lobby)
	#peer.get_peer(player_1["id"]).put_packet((JSON.stringify(send_lobby).to_utf8_buffer()))
	#peer.get_peer(player_2["id"]).put_packet((JSON.stringify(send_lobby).to_utf8_buffer()))

	print(player_1_id)
	print(player_2_id)

	matchmaking.erase(player_1_id)
	matchmaking.erase(player_2_id)

func generate_random_id() -> int:

	var rng = RandomNumberGenerator.new()

	var id_string = ""
	for i in range(0, 9):
		id_string  += str(rng.randi_range(0, 9))

	var id: int = int(id_string)

	return id

func send_to_other_in_lobby(sender_id, data) -> void:

	var lobby = lobbies[users[sender_id]["lobby"]]
	var recipient_id

	if lobby["player_1"] == sender_id:
		recipient_id = lobby["player_2"]
	else:
		recipient_id = lobby["player_1"]

	send_data_as_JSON(recipient_id, data)

func send_data_as_JSON(recipient_id, data) -> void:
	peer.get_peer(recipient_id).put_packet((JSON.stringify(data).to_utf8_buffer()))

func start_server() -> void:

	peer.create_server(8915)
	print("server_started")

func _on_start_server_button_down():
	
	start_server()


func peer_disconnected(id) -> void:
	pass

func peer_connected(id) -> void:

	print("peer_connected")
	var send_id = {

		"data_type" : Data.user_id,
		"id" : id,

	}

	send_data_as_JSON(id, send_id)
	#peer.get_peer(id).put_packet((JSON.stringify(send_id).to_utf8_buffer()))

	print("id should be sent")
	
	users[id] = {

		"id" : id,

	}
