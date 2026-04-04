extends Area2D

@export var follow_player_y := true
@export var speed := 100.0
@export var acceleration := 10.0
@export var wait_time: float = 0.0
@export var warning_early_time: float = 2.5
@export var warning_late_time: float = 1.0
@export var y_follow_speed := 40.0
var player: Node2D
var current_state: State = State.WAIT
enum State { WAIT, WARNING_EARLY, WARNING_LATE, FIRE }

signal finished


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	$Warning.hide()


func _process(delta: float) -> void:
	match current_state:
		State.WAIT:
			# 警告待ち時間が終了すると警告へ移行
			wait_time -= delta
			if wait_time < 0:
				$Warning.show()
				$Warning.play("warning_early")
				current_state = State.WARNING_EARLY
		State.WARNING_EARLY:
			# 警告前半時間が終了すると警告後半へ移行
			warning_early_time -= delta
			if warning_early_time < 0:
				$Warning.play("warning_late")
				$WarningSE.play()
				current_state = State.WARNING_LATE
			
			if not player == null and follow_player_y:
				# Yだけ少し遅れて追尾
				position.y = move_toward(position.y, player.global_position.y, y_follow_speed * delta)
		
		State.WARNING_LATE:
			# 警告後半時間が終了すると発射へ移行
			warning_late_time -= delta
			if warning_late_time < 0:
				$Warning.hide()
				$FireSE.play()
				current_state = State.FIRE
				finished.emit()
				
		State.FIRE:
			speed += acceleration
			position.x -= speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	body.hit_obstacles()
