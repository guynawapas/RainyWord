extends Node
#player instance for each connected player
var id =-1
var player_name=""
var connected_player=null
var scores=[0,0]
var room_id=-1




func set_id(id):
	self.id=id
	self.name=str(id)
	
func set_player_name(name):
	print("set_player_name was called")
	self.player_name=name
	
func timer_start():
	get_node("MatchTimer").start
	
func soft_reset():
	scores=[0,0]
	get_node("MatchTimer").stop
	
func hard_reset():
	soft_reset()
	connected_player=null
