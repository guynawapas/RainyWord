extends Node


var words = [
	"abc",
	"werttw",
	"fsgr",
	"gthj",
	"yuythf",
	"gvbbb"
]

func get_word():
	var word_index = randi()%words.size()
	return words[word_index]
