extends Node3D
## NOTE: This Node is queue_free()-d by the AnimationPlayer when the animation is finished


## This GPUParticles3D Node is all that this HitEffect really is
@onready var Particles: GPUParticles3D = $SmokeParticles

## The Effect just doesn't happen without this
func _ready() -> void:
	Particles.one_shot = true
	Particles.emitting = true

## NOTE: This is called by the Node which spawns the ShotEffect, which is the weapon, probably.
## The first parameter is the position of the end of the barrel;
## the point where this effect is instantiated.
## The second parameter is the normal angle of the effect
#func draw_effect(pos: Vector3, normal: Vector3) -> void:
func draw_effect(pos, total) -> void:
	## Put the effect at the right global_position where the bullet hit
	#self.global_position = pos
	#
	### Make the Particles emit in the same direction as the gun's barrel
	#Particles.process_material.direction = -normal
	
	self.global_position = pos
	self.global_transform.basis = total


func _on_smoke_particles_finished() -> void:
	queue_free()
