extends Node2D

@export var gap_time: float = 0.2
@export var warning_early := 1.2
@onready var missiles: Array = [
	$Missile, $Missile2, $Missile3, $Missile4
]
var lane_index: int = -1
var total_missiles: int = 0
var finished_count: int = 0
var lane_top := -28.0
var lane_bot := 24.0
var pos_x := [ -2, 0, 2, 4 ]
var pos_y := [ -24, -8, 8, 24 ]

signal finished


func _ready() -> void:
	# positionのシャッフル
	pos_x.shuffle()
	pos_y.shuffle()
	# ミサイル合計数の取得
	total_missiles += missiles.size()
	# シグナルとの連結と各ミサイルのポジション指定
	for missile: Area2D in missiles:
		missile.finished.connect(_on_beam_finished)
		missile.position.x = pos_x.pop_front()
		missile.position.y = pos_y.pop_front()
		missile.warning_early_time = warning_early
		missile.wait_time = pos_x.size() * gap_time
	
	position.y = lane_top if randf() < 0.5 else lane_bot


func _on_beam_finished() -> void:
	finished_count += 1
	if finished_count >= total_missiles:
		finished.emit()
		
		await get_tree().create_timer(2.0).timeout
		queue_free()
