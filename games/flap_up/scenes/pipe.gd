extends Node2D

@export var speed := 70.0
@export var speed_bonus := 10.0
var difficulty: int = 0


signal passed


func _process(delta: float) -> void:
	position.x -= (speed + speed_bonus * difficulty) * delta


func _on_top_pipe_body_entered(body: Node2D) -> void:
	body.game_over()
	

func _on_bottom_pipe_body_entered(body: Node2D) -> void:
	body.game_over()


func stop():
	speed = 0


func _on_score_area_body_entered(_body: Node2D) -> void:
	passed.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
