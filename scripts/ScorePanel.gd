extends Control

onready var high_score_number = get_node("HighScoreVBox/HighScoreContainer/HighScoreNumber")
onready var score_number = get_node("ScoreVBox/ScoreContainer/ScoreNumber")
onready var length_number = get_node("LengthVBox/LengthContainer/LengthNumber")

func _ready() -> void:
	pass

func set_high_score(score: int) -> void:
	var highString = str(score)
	highString = highString.pad_zeros(6)
	high_score_number.set_text(highString)

func set_score(new_score: int) -> void:
	var scoreString = str(new_score)
	scoreString = scoreString.pad_zeros(6)
	score_number.set_text(scoreString)
	
func set_length(new_length: int) -> void:
	var lengthString = str(new_length)
	lengthString = lengthString.pad_zeros(3)
	length_number.set_text(lengthString)