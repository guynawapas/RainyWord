extends Node
#player instance for each connected player
var id =- 1
var player_name = ""
var connected_player = null
var room_id =- 1
var wish_for_rematch = false
var player_score = 0



func set_id(id):
	self.id = id
	self.name = str(id)
	
func set_player_name(name):
	self.player_name = name
	

	
func soft_reset():
	player_score = 0
	
func hard_reset():
	soft_reset()
	connected_player = null
	room_id = -1
	wish_for_rematch = false
	
