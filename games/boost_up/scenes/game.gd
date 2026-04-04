extends Node2D

enum State { TITLE, PLAYING, DYING, GAME_OVER, RESTART_WAIT}

@export var static_patterns: Array[PackedScene] = []
@export var charge_patterns: Array[PackedScene] = []          
@export var missile_patterns: Array[PackedScene] = []
var current_state: State = State.TITLE
var progress_level: int = 1
var missile_rate: float = 0.75
var scroll_speed: float = 80.0
var can_spawn_missile: bool = true # 次のミサイルを出してよいか
var can_spawn_obstacles: bool = true # 次の障害を出してよいか
var distance: float = 0.0 # 距離
var speed_step := 2.0     # 1回の加速量
var score_step := 50.0    # 何メートルごとに加速するか
var next_threshold := 50.0 # 次に加速する距離
var score: float = 0.0    # スコア用距離
var messages: Dictionary = {
	"start": "PRESS SPACE / CLICK TO START",
	"retry": "PRESS SPACE / CLICK TO RETRY",
}
enum ObstacleType { STATIC, CHARGE, MISSILE }
var type_data = [
	[
		{ "type": ObstacleType.STATIC, "weight": 8 },
		{ "type": ObstacleType.CHARGE, "weight": 2 },
	],
	[
		{ "type": ObstacleType.STATIC, "weight": 7 },
		{ "type": ObstacleType.CHARGE, "weight": 1 },
		{ "type": ObstacleType.MISSILE, "weight": 2 },
	],
]
var parallax_ratio_mountain_f := 0.7
var parallax_ratio_mountain_b := 0.5
var parallax_ratio_cloud := 0.1


func _ready() -> void:
	update_background_color(0.0, 0.0)
	
	$Player.hit.connect(_on_player_hit)
	$Player.died.connect(_on_player_died)
	$UI/VersionLabel.text = get_version_string()
	# ハイスコア表示
	BoostUpGlobal.load_high_score()
	display_high_score()
	# タイトル表示
	$UI/TitleLabel.show()
	$UI/GameOverLabel.hide()
	update_message_label(messages["start"])
	$UI/MessageLabel.show()
	# プレイヤーをアイドル状態にする
	$Player.current_state = $Player.State.IDLE
	update_background_speed()
	$UI/BackTitleButton.show()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://games/main.tscn")
	
	match current_state:
		State.TITLE:
			if Input.is_action_just_pressed("jump"):
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
					var rect = Rect2(
						$UI/BackTitleButton.position,
						$UI/BackTitleButton.size
					)
					var mouse_pos = get_viewport().get_mouse_position()
					if rect.has_point(mouse_pos):
						return
				
				$UI/TitleLabel.hide()
				$UI/MessageLabel.hide()
				current_state = State.PLAYING
				# プレイヤーを通常状態にする
				$Player.current_state = $Player.State.NORMAL
				$UI/BackTitleButton.hide()
				
		State.PLAYING:
			spawn_obstacles()
			update_score(delta)
			update_progress_lebel()
			
		State.DYING:
			if can_spawn_obstacles:
				can_spawn_obstacles = false
				spawn_static_pattern()
			 
			update_obstacles_speed()
			update_score(delta)
			
		State.GAME_OVER:
			if can_spawn_obstacles:
				can_spawn_obstacles = false
				spawn_static_pattern()

			slow_down_scroll_speed(0.0, 1.5)
			if scroll_speed <= 0.0:
				update_high_score()
				display_high_score()
				current_state = State.RESTART_WAIT
				$UI/GameOverLabel.show()
				update_message_label(messages["retry"])
				$UI/MessageLabel.show()
				
			update_score(delta)
			update_obstacles_speed()
				
		State.RESTART_WAIT:
			if Input.is_action_just_pressed("jump"):
				get_tree().reload_current_scene()
		
	#print("level: ", progress_level, " speed: ", scroll_speed)
	
	
func spawn_static_pattern() -> void:
	# パターンシーンの生成
	var pattern_scene: PackedScene = static_patterns.pick_random()
	var pattern: Node2D = pattern_scene.instantiate()
	# finishedシグナルと接続
	pattern.connect("finished", on_pattern_finished)
	# ポジションをスタート地点へ移動
	pattern.position.x = $Obstacles.position.x
	# パターンのスピードの設定
	pattern.scroll_speed = scroll_speed
	# パターンをシーンへ追加
	$Obstacles.add_child(pattern)


func spawn_charge_pattern(select_first: bool = false) -> void:
	# パターンシーンの生成
	var pattern_scene: PackedScene
	if select_first:
		pattern_scene = charge_patterns[0]
	else:
		pattern_scene = charge_patterns.pick_random()
	var pattern: Node2D = pattern_scene.instantiate()
	# finishedシグナルと接続
	pattern.connect("finished", on_pattern_finished)
	# パターンをシーンへ追加
	$ObstaclesCharge.add_child(pattern)


func spawn_missile_pattern(select_first: bool = false) -> void:
	# パターンシーンの生成
	var pattern_scene: PackedScene
	if select_first:
		pattern_scene = missile_patterns[0]
	else:
		pattern_scene = missile_patterns.pick_random()
	var pattern: Node2D = pattern_scene.instantiate()
	# finishedシグナルと接続
	pattern.connect("finished", on_pattern_finished)
	# パターンをシーンへ追加
	$ObstaclesMissile.add_child(pattern)


func spawn_missile_single() -> void:
	# ミサイル率によりミサイルの出現を判断
	if randf() < missile_rate:
		# パターンシーンの生成
		var pattern_scene: PackedScene = missile_patterns[0]
		var pattern: Node2D = pattern_scene.instantiate()
		# パターンをシーンへ追加
		$ObstaclesMissile.add_child(pattern)
		$MissileTimer.start()
	else:
		$MissileTimer.start()



func on_pattern_finished() -> void:
	can_spawn_obstacles = true


func _on_player_hit() -> void:
	$BirdTimer.stop()
	shake_camera()
	current_state = State.DYING


func _on_player_died() -> void:
	shake_camera()
	current_state = State.GAME_OVER


func update_high_score() -> void:
	# ハイスコアデータの更新
	if score > BoostUpGlobal.high_score:
		BoostUpGlobal.high_score = score
		
		# ハイスコア演出
		$HighScoreSounc.play()
		var label = $UI/HighScoreLabel
		label.modulate = Color(1.0, 0.878, 0.569, 1.0)
		var tween = get_tree().create_tween()
		# 拡大縮小をループ
		label.pivot_offset = label.size / 2
		tween.set_loops(4)
		tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.3)
		tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.3)


func display_high_score() -> void:
	# ハイスコアラベルの更新
	var high_score_int = int(BoostUpGlobal.high_score)
	var high_score_dec = int((BoostUpGlobal.high_score - high_score_int) * 100)
	$UI/HighScoreLabel.text = "HIGH SCORE: %d.%02dM" % [high_score_int, high_score_dec]


func update_message_label(message: String) -> void:
	$UI/MessageLabel/BackLabel.text = message
	$UI/MessageLabel/FrontLabel.text = message


func get_version_string() -> String:
	return "v%d.%d" % [BoostUpGlobal.VERSION, BoostUpGlobal.VERSION_MINOR]


func update_obstacles_speed() -> void:
	for i in $Obstacles.get_children():
		i.scroll_speed = scroll_speed


# 一定距離を進ごとにスクロールスピードを増加
func accelerate_scroll_speed() -> void:
	if score > next_threshold:
		scroll_speed += speed_step
		next_threshold += score_step
		update_obstacles_speed()
		update_background_speed()


# スクロールスピードを徐々に減速する
func slow_down_scroll_speed(speed_min: float, brake_force: float) -> void:
	scroll_speed -= brake_force
	if scroll_speed < speed_min:
		scroll_speed = speed_min
	update_background_speed()


func update_score(delta) -> void:
	distance += scroll_speed * delta
	score = distance / 16
	# スコアラベルの更新
	var score_int = int(score)
	var score_dec = int((score - score_int) * 100)
	$UI/HBoxContainer/ScoreIntLabel.text = str(score_int)
	$UI/HBoxContainer/ScoreDecLabel.text = ".%02dM" % score_dec


# 障害物タイプの抽選
func pick_weighted_type(t_data: Array) -> int:
	var total_weight := 0

	for data in t_data:
		total_weight += data.weight

	var roll := randi_range(1, total_weight)
	var current := 0

	for data in t_data:
		current += data.weight
		if roll <= current:
			return data.type

	return t_data[0].type


# scoreによってprogress_lebelを更新する
func update_progress_lebel() -> void:
	if progress_level <= 1 and score > 60 :
		progress_level = 2
		return
	if progress_level == 2  and score > 85 :
		progress_level = 3
		spawn_bird()
		return
	if progress_level == 3  and score > 200 :
		progress_level = 4
		return
	if progress_level == 4  and score > 300 :
		progress_level = 5
		update_background_color(0.5, 6.0)
		$BirdTimer.start()
		return
	if progress_level == 5  and score > 500 :
		progress_level = 6
		update_background_color(1.0, 6.0)
		$BirdTimer.stop()
		return
	if progress_level == 6  and score > 700 :
		progress_level = 7
		return
	if progress_level == 7  and score > 1000 :
		progress_level = 8
		missile_rate = 1.0
		speed_step = 5.0
		return


func spawn_obstacles() -> void:
	if can_spawn_obstacles:
		can_spawn_obstacles = false
		match progress_level:
			1:
				spawn_static_pattern()
			2:
				spawn_charge_pattern(true)
			3:
				match pick_weighted_type(type_data[0]):
					ObstacleType.STATIC:
						spawn_static_pattern()
					ObstacleType.CHARGE:
						spawn_charge_pattern()
			4:
				spawn_missile_pattern()
			5:
				match pick_weighted_type(type_data[1]):
					ObstacleType.STATIC:
						spawn_static_pattern()
					ObstacleType.CHARGE:
						spawn_charge_pattern()
					ObstacleType.MISSILE:
						spawn_missile_pattern()
			6:
				spawn_static_pattern()
			7:
				match pick_weighted_type(type_data[1]):
					ObstacleType.STATIC:
						spawn_static_pattern()
					ObstacleType.CHARGE:
						spawn_charge_pattern()
					ObstacleType.MISSILE:
						spawn_missile_pattern()
			8:
				match pick_weighted_type(type_data[1]):
					ObstacleType.STATIC:
						spawn_static_pattern()
					ObstacleType.CHARGE:
						spawn_charge_pattern()
					ObstacleType.MISSILE:
						spawn_missile_pattern()
						
	if progress_level >= 6: 
		if can_spawn_missile:
			can_spawn_missile = false
			spawn_missile_single()
			
	accelerate_scroll_speed()


func _on_missile_timer_timeout() -> void:
	can_spawn_missile = true


func update_background_speed() -> void:
	$Background/Cloud.autoscroll.x = -scroll_speed * parallax_ratio_cloud + 4
	$Background/MountainBack.autoscroll.x = -scroll_speed * parallax_ratio_mountain_b
	$Background/MountainFront.autoscroll.x = -scroll_speed * parallax_ratio_mountain_f


func update_background_color(progress: float, duration: float) -> void:
	var tween = create_tween()
	tween.parallel().tween_property(
		$Background/MountainFront/Sprite2D.material,
		"shader_parameter/Progress",
		progress,
		duration
	)
	tween.parallel().tween_property(
		$Background/MountainBack/Sprite2D.material,
		"shader_parameter/Progress",
		progress,
		duration
	)
	tween.parallel().tween_property(
		$Background/Cloud/Sprite2D.material,
		"shader_parameter/Progress",
		progress,
		duration
	)
	tween.parallel().tween_property(
		$Background/Sky.material,
		"shader_parameter/Progress",
		progress,
		duration
	)


func spawn_bird() -> void:
	# パターンシーンの生成
	var bird_scene: PackedScene = load("res://games/boost_up/scenes/bird.tscn")
	var bird: Node2D = bird_scene.instantiate()
	# ポジションを移動
	bird.position = Vector2(128, 0)
	# パターンをシーンへ追加
	$Background.add_child(bird)


func shake_camera():
	var tween = create_tween()
	for i in 6:
		tween.tween_property(
			$Camera2D,
			"offset",
			Vector2(
				randf_range(-6, 6),
				randf_range(-6, 6),
			),
			0.03
		)
	tween.tween_property($Camera2D, "offset", Vector2.ZERO, 0.05)


func _on_bird_timer_timeout() -> void:
	if randf() < 0.3:
		spawn_bird()


func _on_back_title_button_pressed() -> void:
	get_tree().change_scene_to_file("res://games/main.tscn")
