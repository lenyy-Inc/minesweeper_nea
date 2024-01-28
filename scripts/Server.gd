extends Node

enum Data{

	join_queue,
	id,
	wait,
	match_data,

}

var lobbies:= {}
var users:= {}
var matchmaking:= {}
var peer = WebSocketMultiplayerPeer.new()

func _ready():
	peer.peer_connected.connect(peer_connected)
	peer.peer_disconnected.connect(peer_disconnected)

func _process(delta):

	peer.poll()

	if peer.get_available_packet_count() > 0:

		var packet = peer.get_packet()

		if packet != null:

			var data = JSON.parse_string(packet.get_string_from_utf8())

			if data.data_type == Data.join_queue:
				
				matchmaking[data.id] = {

					"id" : data.id,
					"username" : data.username,
					"elo" : data.elo,
					"current_opponent" : null,
					"time_waited" : null,
				}


func matchmake():

	
	var in_matchmaking:= []
	var match_conditions: bool 
	var difference_lenience: int
	var elo_difference: int

	for user in matchmaking:
		in_matchmaking.append(user)
	
	for i in range(0, in_matchmaking.size() - 2):

		var candidate_1 = in_matchmaking[i]

		for j in range(i + 1, in_matchmaking.size() - 1):

			var candidate_2 = in_matchmaking[j]

			elo_difference = candidate_1["elo"] - candidate_2["elo"]
			difference_lenience = 5 * candidate_1["time_waited"] * candidate_2["time_waited"]
			match_conditions = elo_difference <= difference_lenience

			if match_conditions:
				candidate_1["current_opponent"] = candidate_2["id"]
				candidate_2["current_opponent"] = candidate_1["id"]
		
	for user in matchmaking:

		var user_chosen_opponent = matchmaking[user["current_opponent"]]

		if (user_chosen_opponent == null):
			pass

		if user["id"] == user_chosen_opponent["current_opponent"]:
			generate_random_id()
			lobbies[generate_random_string()]

func generate_random_string() -> void:

	var id:= ""
	


func start_server() -> void:

	peer.create_server(8915)
	print("server_started")

func _on_start_server_button_down():
	
	start_server()


func peer_disconnected(id) -> void:
	pass

func peer_connected(id) -> void:
	print("peer_connected")
	users[id] = {

		"id" : id,
		"data_type" : Data.id,

	}
	peer.get_peer(id).put_packet((JSON.stringify(users[id]).to_utf8_buffer()))
