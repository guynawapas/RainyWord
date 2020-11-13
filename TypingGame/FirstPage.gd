extends Node
#######################################################################################
#                                                                                     #
#    FirstPage          ->            Menu              ->                Main        #
#    Player enter name        Player choose game mode                  Actual game    #
#                                                                                     #
#######################################################################################

onready var loading=$CanvasLayer/PanelContainer
onready var scene=$CanvasLayer/PanelContainer/VideoPlayer
#const PORT = 4242
#const IP_ADDRESS = "127.0.0.1"
#var player_name=""
func _ready():
	BgmPlayer.stop()
	get_node("disconnectButton").hide()

func _process(delta):
	if(get_node("nameBox").get_text()!=""):
		get_node("connectButton").disabled=false
	else:
		get_node("connectButton").disabled=true

func _on_connectButton_pressed():
	ClickPlayer.play()
	Lobby.set_player_name(get_node("nameBox").get_text())
	Lobby.on_buttonConnect_pressed()

	
func _on_disconnectButton_pressed():
	ClickPlayer.play()
	Lobby.on_buttonDisconnect_pressed()
	pass
	


func _on_nameBox_text_changed():
	TypePlayer.play()
	pass # Replace with function body.
