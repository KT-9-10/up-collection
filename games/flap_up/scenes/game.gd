extends Node2D

enum State { START, PLAY, GAME_OVER, RESTART_WAIT }

@export var jump_effect_scene: PackedScene

var score: int
var current_state: State
var pipe_scene: PackedScene = preload("res://games/flap_up/scenes/pipe.tscn")
var difficulty: int
var messages: Dictionary = {
	"start": "PRESS SPACE / CLICK TO FLAP",
	"retry": "PRESS SPACE / CLICK TO RETRY",
}
var shake_strength := 0.0


func _ready() -> void:
	FlapUpGlobal.load_high_score()
	$UI/VersionLabel.text = get_version_string()
	# スコアの初期化
	score = 0
	$UI/ScoreLabel.text = str(score)
	$UI/HighScoreLabel.text = "HIGH SCORE: " + str(FlapUpGlobal.high_score)
	# 状態の初期化
	current_state = State.START 
	# UIの初期化
	$UI/TitleLabel.show()
	$UI/GameOverLabel.hide()
	$UI/MessageLabel.text = messages["start"]
	$UI/MessageLabel.show()
	# 難易度の初期化
	difficulty = 0


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://games/main.tscn")
	
	# 死亡時に画面を揺らすための処理
	if shake_strength > 0.0:
		$Camera2D.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength),
		)
		shake_strength -= 0.5


func start_game() -> void:
	current_state = State.PLAY
	$UI/TitleLabel.hide()
	$UI/MessageLabel.hide()
	$SpawnTimer.start()
	$LevelUpTimer.start()


func game_over() -> void:
	current_state = State.GAME_OVER 
	$LevelUpTimer.stop()
	$UI/GameOverLabel.show()
	$GameOverSE.play()
	shake_strength = 10.0 # 画面をシェイクさせる強さの設定
	if score > FlapUpGlobal.high_score:
		# ハイスコアデータの更新
		FlapUpGlobal.high_score = score
		FlapUpGlobal.save_high_score()
		
		# ハイスコアラベルの更新
		var label = $UI/HighScoreLabel
		$UI/HighScoreLabel.text = "HIGH SCORE: " + str(FlapUpGlobal.high_score)
		
		# ハイスコア演出
		label.modulate = Color(1, 0.9, 0.3)
		var tween = get_tree().create_tween()
		# ① まず中央に移動（1回だけ）
		var center_pos = get_viewport_rect().size / 2 - label.size / 2
		var offset_pos = center_pos + Vector2(0, 40)
		tween.tween_property(label, "position", offset_pos, 0.2)
		# ② 拡大縮小をループ
		label.pivot_offset = label.size / 2
		tween.set_loops(5)
		tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.3)
		tween.tween_property(label, "scale", Vector2(1, 1), 0.3)
		
	await get_tree().create_timer(1.5).timeout
	$UI/MessageLabel.text = messages["retry"]
	$UI/MessageLabel.show()
	current_state = State.RESTART_WAIT


func spawn_pipe() -> void:
	var pipe: Node2D = pipe_scene.instantiate()
	pipe.position = Vector2(170, randf_range(-32, 32))
	pipe.connect("passed", add_score)
	$Obstacles.add_child(pipe)
	pipe.difficulty = difficulty

	
func add_score() -> void:
	if current_state == State.PLAY:
		# スコアの更新
		score += 1
		$UI/ScoreLabel.text = str(score)
		# スコアラベルのアニメーション
		$UI/ScoreLabel.pivot_offset = $UI/ScoreLabel.size / 2 # 起点を中心に
		var tween = get_tree().create_tween()
		tween.tween_property($UI/ScoreLabel, "scale", Vector2(1.5, 1.5), 0.1)
		tween.tween_property($UI/ScoreLabel, "scale", Vector2(1, 1), 0.1)
		# SEの再生
		$PassedSE.play()


func get_version_string() -> String:
	return "v%d.%d" % [FlapUpGlobal.VERSION, FlapUpGlobal.VERSION_MINOR]


func spawn_pass_effect(pos: Vector2):
	var effect: GPUParticles2D = jump_effect_scene.instantiate()
	effect.position = pos
	effect.difficulty = difficulty
	add_child(effect)


func _on_timer_timeout() -> void:
	spawn_pipe()


func _on_level_up_timer_timeout() -> void:
	# 難易度上昇
	difficulty += 1
	for p in $Obstacles.get_children():
		p.difficulty = difficulty
	# パイプの発声間隔を短く
	$SpawnTimer.wait_time *= 0.95
