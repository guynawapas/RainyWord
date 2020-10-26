extends Button


const PORT = 4242
const IP_ADDRESS = "127.0.0.1"
var player_name="default"

func _on_buttonConnect_pressed():
	pass
	

remote func sendName(name):
	
	pass
func _on_connection_success():
	print("success")
	print(self.get_path())
	player_name=get_parent().get_node("LineEditPlayerName").text
	rpc_id(1,"test")
	rpc_id(1,"set_player_name",player_name)
