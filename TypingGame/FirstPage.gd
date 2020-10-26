extends Node
#######################################################################################
#                                                                                     #
#    FirstPage          ->            Menu              ->                Main        #
#    Player enter name        Player choose game mode                  Actual game    #
#                                                                                     #
#######################################################################################


const PORT = 4242
const IP_ADDRESS = "127.0.0.1"
var player_name=""


func _process(delta):
	if(get_node("nameBox").get_text()!=""):
		get_node("connectButton").disabled=false
	else:
		get_node("connectButton").disabled=true

func _on_connectButton_pressed():
	Lobby.set_player_name(get_node("nameBox").get_text())
	Lobby.on_buttonConnect_pressed()
	pass
	
func _on_disconnectButton_pressed():
	Lobby.on_buttonDisconnect_pressed()
	pass
	
