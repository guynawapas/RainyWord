extends Node
#player instance for each connected player
var id =- 1
var player_name = ""
var connected_player = null
var room_id =- 1
var wish_for_rematch = false
var player_score = 0



func set_id(id):
	self.id=id
	self.name=str(id)
	
func set_player_name(name):
	print("set_player_name was called")
	self.player_name=name
	
func timer_start():
	get_node("MatchTimer").start()
	
func soft_reset():
	get_node("MatchTimer").stop()
	
func hard_reset():
	soft_reset()
	connected_player=null
