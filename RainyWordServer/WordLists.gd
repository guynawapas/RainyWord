extends Node


var wordLists =[
	"asda",
"sgsdfdf",
"wevc",
"chula",
"longkorn",
"yeehah"]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_word():
	var index = randi()%wordLists.size()
	return wordLists[index]
