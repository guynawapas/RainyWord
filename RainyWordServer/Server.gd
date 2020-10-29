extends Node


const PORT = 4242
const MAX_PLAYERS = 200
const IP_ADDRESS = "127.0.0.1"
var totalUserCount= ""
onready var players = $Players
onready var matching = $Matching
onready var rooms = $Rooms
onready var playing = $Playing
onready var single_player_room = $SinglePlayerRoom
onready var single_player = $SinglePlayer

func _ready():
	var network = NetworkedMultiplayerENet.new()
	network.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	Lobby.players = players
	Lobby.matching = matching
	Lobby.rooms = rooms
	Lobby.playing = playing
	Lobby.single_player_room = single_player_room
	Lobby.single_player = single_player
	print("listening on port",PORT)
	
func _peer_connected(id):
	totalUserCount = str(get_tree().get_network_connected_peers().size())
	get_node("labelConnectDisconnectAlert").text = "\nUser "+str(id)+ " connected"
	get_node("labelTotalClient").text = "Total users: " + totalUserCount
	Lobby.peer_connected(id)
	listAllClient()
	print(totalUserCount)
	print("Client ",id," connected")
	
func _peer_disconnected(id):
	totalUserCount=str(get_tree().get_network_connected_peers().size())
	get_node("labelConnectDisconnectAlert").text = "\nUser "+str(id)+ " disconnected"
	get_node("labelTotalClient").text = "Total users: " + totalUserCount
	Lobby.peer_disconnected(id)
	listAllClient()
	print(totalUserCount)
	print("Client ",id," disconnected")
	
	
func listAllClient():
	var listOfClients="Client:"
	for player in players.get_children():
		listOfClients+="\n\t"+str(player.id)
	get_node("labelClientList").text = listOfClients


func _on_Restart_pressed():#disconnect all clients
	for player in players.get_children():
		player.queue_free()	
	for player in matching.get_children():
		player.queue_free()	
	for player in rooms.get_children():
		player.queue_free()

