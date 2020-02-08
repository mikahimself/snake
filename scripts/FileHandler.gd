extends Node

const SAVE_FILE_PATH = "user://scoredata.bin"
const INITIAL_SCORE = 100

func load_high_score() -> int:
	var save_file = File.new()

	if not save_file.file_exists(SAVE_FILE_PATH):
		return INITIAL_SCORE
	save_file.open(SAVE_FILE_PATH, File.READ)
	var scoredata = parse_json(save_file.get_as_text())
	var score = scoredata["score"]
	save_file.close()
	return score

func save_high_score(score: int):
	if score > load_high_score():
		var save_data = { "score" : score}
		var save_file = File.new()
		save_file.open(SAVE_FILE_PATH, File.WRITE)
		save_file.store_line(to_json(save_data))
		save_file.close()
	else:
		return
