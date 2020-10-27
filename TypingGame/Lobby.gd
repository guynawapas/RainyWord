extends Node


const PORT = 4242
const IP_ADDRESS = "127.0.0.1"

var player_name= ""
var opponent_name= ""
var is_singlePlayer = false
var player_score = 0
var opponent_score = 0
var room_id  = -1


func set_player_name(name):
	self.player_name = name
	

func on_buttonConnect_pressed():
	var network = NetworkedMultiplayerENet.new()
	network.create_client(IP_ADDRESS,PORT)
	get_tree().set_network_peer(network)
	print("connecting to server")
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_success")
	network.connect("server_disconnected",self,"_on_server_disconnected")
	
	
func _on_connection_success():
	print("success")
	#set player name in server and go to menu screen
	rpc_id(1,"set_player_name",player_name)
	get_tree().change_scene("res://Menu.tscn")
	
func _on_server_disconnected():
	get_tree().change_scene("res://FirstPage.tscn")

func on_buttonDisconnect_pressed():
	get_tree().set_network_peer(null)

func on_singlePlayer_pressed():
	rpc_id(1,"singlePlayer")
#	Global.emit_signal("singlePlayer")
	is_singlePlayer = true
	
func player_gain_score():
	self.player_score += 1
	rpc_id(1,"player_gain_score",self.player_score,room_id)
	
remote func opponent_gain_score():
	print(opponent_name + "gained score!")
	self.opponent_score += 1

func find_match_pressed():
	rpc_id(1,"find_match")
	
remote func got_opponent(opponent_name,room_id):
#	Global.emit_signal("set_opponent_name",opponent)
	self.opponent_name = opponent_name
	self.room_id = room_id
	print("got opponent",opponent_name)
	get_tree().change_scene("res://Game.tscn")
	
remote func soft_reset():
	player_score = 0
	opponent_score = 0

remote func hard_reset():
	player_name= ""
	opponent_name= ""
	is_singlePlayer = false
	player_score = 0
	opponent_score = 0
