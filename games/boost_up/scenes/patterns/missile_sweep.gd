extends Node2D

@export var gap_time: float = 0.7
@export var warning_early := 1.2
@onready var missiles: Array = [
	$Missile, $Missile2, $Missile3, $Missile4, $Missile5, $Missile6, $Missile7
]
var lane_index: int = -1
var total_missiles: int = 0
var finished_count: int = 0
var lane_top := -24.0
var lane_bot := 24.0

signal finished


func _ready() -> void:
	# 1/2の確立でpositionの反転
	if randi_range(0, 1) == 0:
		missiles.reverse()
	# ミサイル合計数の取得
	total_missiles += missiles.size()
	# wait_time計算用の変数
	var gap_multi := 0
	# シグナルとの連結と各ミサイルのポジション指定
	for missile: Area2D in missiles:
		missile.finished.connect(_on_beam_finished)
		missile.warning_early_time = warning_early
		missile.wait_time = gap_multi * gap_time
		gap_multi += 1


func _on_beam_finished() -> void:
	finished_count += 1
	if finished_count >= total_missiles:
		finished.emit()
		
		await get_tree().create_timer(2.0).timeout
		queue_free()
