extends Node2D

var lane_top := -60.0
var lane_bot := 38.0
var player: Node2D

signal finished


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	# シグナルとの連結
	$BeamCharge.finished.connect(_on_beam_finished)
	position.y = player.position.y

func _on_beam_finished() -> void:
	finished.emit()
	await get_tree().create_timer(2.0).timeout
	queue_free()
