extends Node

const SAVE_PATH := "user://kt910_flap_up_highscore.json"
const VERSION := 1
const VERSION_MINOR := 1
const SECRET := "tiny_action_big_results"

var high_score := 0


func save_high_score() -> void:
	var data = {
		"high_score": high_score,
		"version": VERSION,
		"checksum": make_checksum(high_score, VERSION)
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


func load_high_score() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		high_score = 0
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var json = JSON.new()
		
		var error = json.parse(text)
		if error != OK:
			high_score = 0
			return

		var data = json.data
		
		if not (data is Dictionary):
			print("Save data is not a Dictionary")
			high_score = 0
			return
		
		if not data.has("version"):
			print("Missing version")
			high_score = 0
			return
		
		var loaded_version := int(data["version"])
		if loaded_version != VERSION:
			print("Save version mismatch")
			high_score = 0
			return

		if not data.has("high_score"):
			print("Missing high score")
			high_score = 0
			return
		
		if not data.has("checksum"):
			print("Missing checksum")
			high_score = 0
			return
		
		var loaded_high_score := int(data["high_score"])
		var expected_checksum := make_checksum(loaded_high_score, loaded_version)
		if expected_checksum != str(data["checksum"]):
			print("Checksum mismatch")
			high_score = 0
			return

		high_score = loaded_high_score


func make_checksum(score: int, version: int) -> String:
	var text = str(score) + "|" + str(version) + "|" + SECRET
	return text.sha256_text()
	
