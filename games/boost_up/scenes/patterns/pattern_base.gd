extends Node2D
class_name PatternBase

@export var scroll_speed: float = 60
@export var finish_notifier_x: float = -184
@export var pos_x := 32
var lane_index: int = -1


func _ready() -> void:
	$FinishNotifier.position.x = finish_notifier_x


func _process(delta: float) -> void: 
	# 移動
	position.x -= scroll_speed * delta
