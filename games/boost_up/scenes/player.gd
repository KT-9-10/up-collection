extends CharacterBody2D

enum State { IDLE, NORMAL, HIT, DEAD }

@export var jump_force := 10
@export var gravity := 320
@export var max_rise_speed := 120
@export var max_fall_speed := 120

var current_state: State = State.NORMAL
var hit_timer: float = 0
var was_in_air: bool

signal hit
signal died


func _physics_process(delta: float) -> void:
	match current_state:
		State.NORMAL:
			# ジャンプ入力
			if Input.is_action_pressed("jump"):
				velocity.y -= jump_force
				# 上昇スピードを制限する
				if velocity.y < -max_rise_speed:
					velocity.y = -max_rise_speed
				# 降下スピードを制限する
				if velocity.y > max_fall_speed:
					velocity.y = max_fall_speed
				if not $MachinegunSound.playing:
					$MachinegunSound.play()
			else:
				$MachinegunSound.stop()

		State.HIT:
			$MachinegunSound.stop()
			# 死んですぐはState.DEADに移行しないようにする
			hit_timer += delta
			if hit_timer > 0.2 and is_on_floor():
				current_state = State.DEAD
				died.emit()
	# 重力の適用
	velocity.y += gravity * delta
	move_and_slide()
	update_animation()
	play_landing_sound()


func update_animation() -> void:
	match current_state:
		State.NORMAL:
			if is_on_floor():
				$AnimatedSprite2D.play("run")
				return
			if Input.is_action_pressed("jump"):
				$AnimatedSprite2D.play("boost_up")
				return
			if velocity.y <= 0:
				$AnimatedSprite2D.play("jump_up")
			else:
				$AnimatedSprite2D.play("jump_down")
		State.HIT:
			$AnimatedSprite2D.play("hit")
			rotation += 0.25 # Spriteの回転
		State.DEAD:
			$AnimatedSprite2D.play("dead")
			rotation = 0.0


# 障害とぶつかると障害側のメソッドから呼ばれる
func hit_obstacles() -> void:
	if current_state == State.DEAD:
		return
	hit.emit()
	velocity.y = -160
	hit_timer = 0
	current_state = State.HIT
	$HitSound.play()


func play_landing_sound() -> void:
	if is_on_floor():
		if was_in_air:
			if current_state == State.HIT or current_state == State.DEAD:
				$LandingSound.volume_db = 2
			else:
				$LandingSound.volume_db = -6
			$LandingSound.play()
			was_in_air = false
	else:
		was_in_air = true
