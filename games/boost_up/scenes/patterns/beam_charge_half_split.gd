extends Node2D

@export var gap_time: float = 2.7
@onready var beams: Array = [
	[$BeamCharge4, $BeamCharge5, $BeamCharge6, $BeamCharge8],
	[$BeamCharge, $BeamCharge2, $BeamCharge3, $BeamCharge7]
]
var lane_index: int = -1
var total_beams: int = 0
var finished_count: int = 0

signal finished


func _ready() -> void:
	# ビームの数の取得とシグナルとの連結
	for i in beams:
		total_beams += i.size()
		for j in i:
			j.finished.connect(_on_beam_finished)
	
	if  lane_index >= 0 and lane_index < beams.size():
		for lane: BeamBase in beams[lane_index]:
			lane.wait_time += gap_time
	else:
		for lane: BeamBase in beams[randi_range(0, beams.size() - 1)]:
			lane.wait_time += gap_time

func _on_beam_finished() -> void:
	finished_count += 1
	if finished_count >= total_beams:
		finished.emit()
		
		await get_tree().create_timer(2.0).timeout
		queue_free()
