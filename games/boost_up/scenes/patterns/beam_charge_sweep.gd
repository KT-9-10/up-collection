extends Node2D

@export var gap_time: float = 1.5
@onready var beams: Array = [
	$BeamCharge4, 
	$BeamCharge8, 
	$BeamCharge5, 
	$BeamCharge6, 
	$BeamCharge, 
	$BeamCharge2, 
	$BeamCharge3, 
]
var lane_index: int = -1
var total_beams: int = 0
var finished_count: int = 0
var gap_multiplier: int = 0 

signal finished


func _ready() -> void:
	if randi_range(1,2) == 1:
		beams.reverse()
	
	# ビームの数の取得
	total_beams += beams.size()
	# シグナルの連結と待機時間の変更
	for beam in beams:
		beam.finished.connect(_on_beam_finished)
		beam.wait_time += gap_time * gap_multiplier
		gap_multiplier += 1
	

func _on_beam_finished() -> void:
	finished_count += 1
	if finished_count >= total_beams:
		finished.emit()
		
		await get_tree().create_timer(2.0).timeout
		queue_free()
