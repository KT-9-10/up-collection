extends BeamBase

@export var loop_count: int = 1
@export var play_se: bool = false
@export var appear_time: float = 1.5
@export var wait_time: float = 0.5
@export var charge_step_time: float = 0.6
@export var fire_time: float = 0.8
@export var retreat_time: float = 1.0
var current_state: State = State.APPEAR
var pitch_scale: float

enum State { APPEAR, CHARGE, FIRE, RETREAT }

signal finished


func _ready() -> void:
	super()
	$BeamBody.hide()
	$CollisionBody.disabled = true
	
	var tween = create_tween()
	tween.tween_property($BeamStart, "offset", Vector2.ZERO, appear_time).from(Vector2(-16, 0))
	tween.parallel().tween_property($BeamEnd, "offset", Vector2.ZERO, appear_time).from(Vector2(16, 0))
	await tween.finished
	
	for i in loop_count:
		await get_tree().create_timer(wait_time).timeout
		
		if play_se:
			pitch_scale = 1.2
			$ChargeSound.pitch_scale = pitch_scale
			$ChargeSound.play()
		change_sprite("charge_1", [$BeamStart, $BeamEnd])
		await get_tree().create_timer(charge_step_time).timeout
		
		change_sprite("charge_2", [$BeamStart, $BeamEnd])
		await get_tree().create_timer(charge_step_time).timeout
		
		change_sprite("charge_3", [$BeamStart, $BeamEnd])
		await get_tree().create_timer(charge_step_time).timeout
		
		if play_se:
			pitch_scale = 1.4
		change_sprite("charge_4", [$BeamStart, $BeamEnd])
		await get_tree().create_timer(charge_step_time).timeout
		
		change_sprite("charge_5", [$BeamStart, $BeamEnd])
		await get_tree().create_timer(charge_step_time).timeout
		
		if play_se:
			$ChargeSound.stop()
			$FireSound.play()
		change_sprite("fire", [$BeamStart, $BeamEnd, $BeamBody])
		$BeamBody.show()
		$CollisionBody.disabled = false
		await get_tree().create_timer(fire_time).timeout
		
		change_sprite("default", [$BeamStart, $BeamEnd])
		$BeamBody.hide()
		$CollisionBody.disabled = true
	
	finished.emit()
	
	tween = create_tween()
	tween.tween_property($BeamStart, "offset", Vector2(-16, 0), retreat_time)
	tween.parallel().tween_property($BeamEnd, "offset", Vector2(16, 0), retreat_time)
	await tween.finished
	
	queue_free()
	
	
func change_sprite(anim_name: String, sprites: Array) -> void:
	for sprite: AnimatedSprite2D in sprites:
		sprite.play(anim_name)
		sprite.frame = 0
		sprite.frame_progress = 0.0


func _on_charge_sound_finished() -> void:
	$ChargeSound.stop()
	$ChargeSound.pitch_scale = pitch_scale
	$ChargeSound.play()
