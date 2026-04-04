extends CharacterBody2D

var scroll_speed := 0.0
var jump_strength := 230
var gravity := 650
var max_fall_speed := 400
var auto_jump_y := -10
var can_jump := true
@onready var game = get_parent().get_parent()


func _process(delta: float) -> void:
	if game:
		scroll_speed = game.scroll_speed
	
	if can_jump and position.y > auto_jump_y:
		jump()
		$JumpSE.play()
		auto_jump_y = randi_range(-20, 40)
		can_jump = false
		$JumpTimer.start()
		# 重力の適用
	velocity.y += gravity * delta
	# Spriteの回転
	rotation = deg_to_rad(clamp(velocity.y * 0.1, -15, 45))
	# 最大落下スピードを超えないようにする
	velocity.y = min(velocity.y, max_fall_speed)
	
	move_and_slide()
	
	# 移動
	position.x -= (scroll_speed - 60) * delta 


func jump() -> void:
	velocity.y = 0
	velocity.y -= jump_strength


func _on_jump_timer_timeout() -> void:
	can_jump = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
