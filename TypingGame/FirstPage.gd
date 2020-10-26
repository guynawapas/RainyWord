extends Node


const PORT = 4242
const IP_ADDRESS = "127.0.0.1"
var player_name=""


func _process(delta):
	if(get_node("LineEditPlayerName").get_text()!=""):
		get_node("buttonConnect").disabled=false
	else:
		get_node("buttonConnect").disabled=true

func _on_connectButton_pressed():
#	Lobby.set_player_name(get_node("LineEditPlayerName").get_text())
#	Lobby.on_buttonConnect_pressed()
	pass
	
func _on_disconnectButton_pressed():
#	Lobby.on_buttonDisconnect_pressed()
	pass
	
func _on_Button_pressed():
	get_tree().change_scene("res://Main.tscn")
	pass # Replace with function body.
