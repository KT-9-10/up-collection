extends Area2D
class_name BeamBase

@export var body_length: int = 16:
	set(value):
		body_length = value
		update_beam()

func _ready() -> void:
	update_beam()
	for sprite: AnimatedSprite2D in [$BeamStart, $BeamBody, $BeamEnd]:
		sprite.play("default")
		sprite.frame = 0
		sprite.frame_progress = 0.0


func update_beam() -> void:
	if not is_node_ready():
		return
	
	$BeamBody.scale.x = body_length / 16.0
	$BeamEnd.position.x = body_length + 16.0
	$CollisionBody.scale.x = (body_length + 16) / 16.0
	$CollisionBody.position.x = body_length / 2.0 + 16.0


func _on_body_entered(body: Node2D) -> void:
	body.hit_obstacles()
