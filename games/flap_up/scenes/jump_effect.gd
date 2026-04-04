extends GPUParticles2D

@export var velocity := 100.0
@export var velocity_bonus := 20.0
var difficulty: int = 0


func _ready() -> void:
	var mat = process_material as ParticleProcessMaterial
	mat.initial_velocity_max = (velocity + velocity_bonus * difficulty)
	restart()
	emitting = true
	await get_tree().create_timer(1.0).timeout
	queue_free()
