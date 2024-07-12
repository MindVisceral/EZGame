extends Node3D
## NOTE: This Node is queue_free()-d when the Particles Node is finished


## This GPUParticles3D Node is all that this Shot Effect really is
@onready var Particles: GPUParticles3D = $SmokeParticles


## The Effect just doesn't happen without this
func _ready() -> void:
	Particles.one_shot = true
	Particles.emitting = true

## NOTE: This is called by the Node which spawns the ShotEffect, which is the weapon probably.
## The parameter is used to transform this Emitter so that the Effect at the same location as
## the gun's barrel and it ahs the same rotation.
func draw_effect(global_transform_value: Transform3D) -> void:
	self.global_transform = global_transform_value

## Delete this Node once it's done.
func _on_smoke_particles_finished() -> void:
	queue_free()
