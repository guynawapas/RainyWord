extends Node

var id =- 1
var connected_players = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_id(id):
	self.id = id
	self.name = str(id)

	
