extends Node2D

var lane_top := -60.0
var lane_bot := 38.0
@export var speed := 20.0
@export var direction := 1
@onready var beam_charge = $BeamCharge

signal finished


func _ready() -> void:
	# シグナルとの連結
	beam_charge.finished.connect(_on_beam_finished)
	
	direction = [-1, 1].pick_random()
	beam_charge.position.y = randf_range(lane_top, lane_bot)


func _process(delta: float) -> void:
	if beam_charge:
		if $BeamCharge.position.y < lane_top or $BeamCharge.position.y > lane_bot:
			direction *= -1

		beam_charge.position.y += speed * direction * delta


func _on_beam_finished() -> void:
	finished.emit()
	await get_tree().create_timer(2.0).timeout
	queue_free()
