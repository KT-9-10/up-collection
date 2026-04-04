extends Control

var can_play_se := false


@export var player_region_y: int = 16:
	set(value):
		player_region_y = value
		var atlas = $HBoxContainer/VBoxContainer/HBoxContainer2/MarginContainer2/Player.texture as AtlasTexture
		atlas.region = Rect2i(Vector2i(64, player_region_y), Vector2i(16, 16))


func _ready() -> void:
	$HBoxContainer/VBoxContainer/HBoxContainer/FlapUpButton.grab_focus()


func _on_flap_up_button_pressed() -> void:
	$MoveSE.stop()
	$SelectSE.play()
	await $SelectSE.finished
	get_tree().change_scene_to_file("res://games/flap_up/scenes/game.tscn")


func _on_boost_up_button_pressed() -> void:
	$MoveSE.stop()
	$SelectSE.play()
	await $SelectSE.finished
	get_tree().change_scene_to_file("res://games/boost_up/scenes/game.tscn")


func _on_flap_up_button_focus_entered() -> void:
	if can_play_se:
		$MoveSE.play()
	else:
		can_play_se = true


func _on_boost_up_button_focus_entered() -> void:
	if can_play_se:
		$MoveSE.play()
	else:
		can_play_se = true
