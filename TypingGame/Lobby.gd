extends Node


const PORT = 4242
const IP_ADDRESS = "127.0.0.1"
var player_name=""




func set_player_name(name):
	self.player_name = name

func on_buttonConnect_pressed():
	var network = NetworkedMultiplayerENet.new()
	network.create_client(IP_ADDRESS,PORT)
	get_tree().set_network_peer(network)
	print("connecting to server")
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_success")
	
func _on_connection_success():
	print("success")
	#set player name in server and go to menu screen
	rpc_id(1,"set_player_name",player_name)
	get_tree().change_scene("res://Menu.tscn")

func on_buttonDisconnect_pressed():
	get_tree().set_network_peer(null)

func find_match_pressed():
	rpc_id(1,"find_match")
	


remote func accept_match():
	get_tree().change_scene("res://Match.tscn")
