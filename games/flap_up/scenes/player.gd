extends CharacterBody2D

@export var jump_strength := 230
@export var gravity := 650
@export var max_fall_speed := 400
@onready var game = get_parent()


func _physics_process(delta: float) -> void:
	match game.current_state:
		game.State.START:
			if Input.is_action_just_pressed("jump"):
				game.start_game()
				jump()
				$JumpSE.play()
		game.State.PLAY:
			# ジャンプ入力受付
			if Input.is_action_just_pressed("jump"):
				jump()
				$JumpSE.play()
			# 重力の適用
			velocity.y += gravity * delta
			# Spriteの回転
			rotation = deg_to_rad(clamp(velocity.y * 0.1, -15, 45))
			# 最大落下スピードを超えないようにする
			velocity.y = min(velocity.y, max_fall_speed)
		game.State.GAME_OVER:
			# 重力の適用
			velocity.y += gravity * delta
			# Spriteの回転
			rotation += 0.5
		game.State.RESTART_WAIT:
			if Input.is_action_just_pressed("jump"):
				get_tree().reload_current_scene()
				return
			# 重力の適用
			velocity.y += gravity * delta
			# Spriteの回転
			rotation += 0.5
	
	move_and_slide()


func jump() -> void:
	velocity.y = 0
	velocity.y -= jump_strength
	game.spawn_pass_effect(position + Vector2(0, -12))

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	game_over()


func game_over():
	if game.current_state == game.State.PLAY:
		game.game_over()
		velocity.x = randf_range(-100, 100)
		if position.y > 0:
			jump()
		else:
			velocity.y = 0
