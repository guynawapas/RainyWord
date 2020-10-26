extends Node


const PORT = 4242
const IP_ADDRESS = "127.0.0.1"
var player_name=""

func _ready():
	
	pass
func _process(delta):
	if(get_node("LineEditPlayerName").get_text()!=""):
		get_node("buttonConnect").disabled=false
	else:
		get_node("buttonConnect").disabled=true

func _on_buttonConnect_pressed():
	Lobby.set_player_name(get_node("LineEditPlayerName").get_text())
	Lobby.on_buttonConnect_pressed()

func _on_buttonDisconnect_pressed():
	Lobby.on_buttonDisconnect_pressed()
