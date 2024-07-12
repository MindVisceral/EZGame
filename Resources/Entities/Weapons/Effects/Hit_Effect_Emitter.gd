extends Node3D

## This GPUParticles3D Node is all that this HitEffect really is
@onready var Particles: GPUParticles3D = $Particles

## The Effect just doesn't happen without this. Also done for ease of editing through the Editor
func _ready() -> void:
	Particles.one_shot = true
	Particles.emitting = true

## NOTE: This is called by the Node which spawns the HitEffect!
## NOTE: (that's either the weapon itself or the projectile bullet)
## The first parameter is the position which the bullet hit
## The second parameter is the normal angle at which the Bullet hit
func draw_effect(pos: Vector3, normal: Vector3) -> void:
	## Put the effect at the right global_position where the bullet hit
	self.global_position = pos
	
	## Make the Particles explode in the same direction as the hit object's Normals
	Particles.process_material.direction = normal

## This Node is queue_free()-d when the Particles are done
func _on_timer_timeout() -> void:
	queue_free()
