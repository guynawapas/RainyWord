extends Node




func _on_FindMatch_pressed():
	Lobby.find_match_pressed()
	



func _on_SinglePlayer_pressed():
	get_tree().change_scene("res://Main.tscn")
