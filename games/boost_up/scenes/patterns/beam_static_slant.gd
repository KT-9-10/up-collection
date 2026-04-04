extends PatternBase

var lane_top := -32.0
var lane_mid := -2.0
var lane_bot := 24.0
var lanes: Array = [lane_top, lane_mid, lane_bot]
@onready var beams: Array = [$BeamStatic, $BeamStatic2]
var can_emit := true

signal finished


func _ready() -> void:
	super()
	set_lane_position()
	beams.pick_random().queue_free()

func set_lane_position() -> void:
	if lane_index >= 0 and lane_index < lanes.size():
		position.y = lanes[lane_index]
	else:
		position.y = lanes[randi_range(0, lanes.size() - 1)]
	
	position.y = randf_range(lane_top, lane_bot)


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
