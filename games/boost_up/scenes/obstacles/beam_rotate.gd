@tool
extends BeamBase

var rotatetion_speed: float
@export var rotatetion_speed_min := 80
@export var rotatetion_speed_max := 210
@export var rotation_dir := 1


func _ready() -> void:
	for sprite: AnimatedSprite2D in $Sprites.get_children():
		sprite.play("default")
		sprite.frame = 0
		sprite.frame_progress = 0.0
	
	rotation_dir = [-1, 1].pick_random()
	rotatetion_speed = randf_range(rotatetion_speed_min, rotatetion_speed_max)


func _process(delta: float) -> void:
	rotation += deg_to_rad(rotatetion_speed * rotation_dir * delta)
