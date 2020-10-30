extends Node


var wordLists =["hangman", "chairs", "backpack", "bodywash", "clothing",
				 "computer", "python", "program", "glasses", "sweatshirt",
				 "sweatpants", "mattress", "friends", "clocks", "biology",
				 "algebra", "suitcase", "knives", "ninjas", "shampoo",'rainbow', 
	'computer', 'science', 'programming','python', 'mathematics', 
	'player', 'condition', 'reverse', 'water', 'board', 'geeks',
	'all', 'your', 'base',"geography", "cat", "yesterday", "java",
	"truck", "opportunity","fish", "token", "transportation", "bottom",
	 "apple", "cake","remote", "boots", "terminology", "arm", "cranberry", 
	"tool","caterpillar", "spoon", "watermelon", "laptop", "toe", "toad",
	"fundamental", "capitol", "garbage", "anticipate", "pesky","writer", 
	"that", "program","abstract", "assert", "boolean", "break", "byte", 
	"case", "catch", "char", "class", "const","continue", "default", 
	"double", "do", "else", "enum", "extends", "false", "final", 
	"finally","float", "for", "goto", "if", "implements",  "import", 
	"instanceof", "int", "interface", "long","native", "new", "null", 
	"package", "private",  "protected", "public", "return", "short", 
	"static","strictfp", "super", "switch", "synchronized", "this", 
	"throw", "throws", "transient", "true","try", "void", "volatile", 
	"while","reddit", "facebook", "java", "assignment","game", "hello", 
	"islam", "religion", "internet", "face","terminator", "banana", 
	"computer", "cow", "rain", "water","lion", "umbrella", "window", 
	"glass", "juice", "chair", "desktop","laptop", "dog", "cat", "lemon", 
	"cabel", "mirror", "hat","insert", "your", "words", "in", "this", 
	"python", "list",'pear', 'mango', 'apple', 'banana', 'apricot', 
	'pineapple','cantaloupe', 'grapefruit','jackfruit','papaya',
	'hawkeye', 'robin', 'Galactus', 'thor', 'mystique', 'superman', 
	'deadpool', 'vision', 'sandman', 'aquaman']


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_word():
	randomize()
	var index = randi()%wordLists.size()
	return wordLists[index]
