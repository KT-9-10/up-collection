extends PatternBase

var lane_top := -57.0
var lane_mid := -10.0
var lane_bot := 37.0
var lanes: Array = [lane_top, lane_mid, lane_bot]
var can_emit := true

signal finished


func _ready() -> void:
	super()
	set_lane_position()


func set_lane_position() -> void:
	if lane_index >= 0 and lane_index < lanes.size():
		lanes.pop_at(lane_index)
		$BeamStatic.position.y = lanes.pop_front()
		$BeamStatic2.position.y = lanes.pop_front()
	else:
		lanes.pop_at(randi_range(0, lanes.size() - 1))
		$BeamStatic.position.y = lanes.pop_front()
		$BeamStatic2.position.y = lanes.pop_front()


func _process(_delta: float) -> void:
	super._process(_delta)
	if can_emit and global_position.x < pos_x:
		can_emit = false
		finished.emit()


func _on_finish_notifier_screen_exited() -> void:
	#finished.emit()
	pass


func _on_delete_notifier_screen_exited() -> void:
	queue_free()
