extends Node


var wordLists =["asda","sgsdfdf","wevc"]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_ran_words():
	var ran_words=[]
	for i in range (500):
		var choice = wordLists[randi()%wordLists.size()]
		if ran_words.find(choice):
			pass
		else:
			ran_words[i]=choice
		
