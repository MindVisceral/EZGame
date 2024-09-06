## We want the particles_colour variable to work in-Editor
@tool
extends Node3D
## NOTE: This Node is queue_free()-d by the AnimationPlayer when
## the Hit Effect animation is finished


## This GPUParticles3D Node is all that this HitEffect really is
@onready var Particles: GPUParticles3D = $Particles

## Alpha value is used for particle Transparency
@export var particles_colour: Color = Color.YELLOW

## The Effect just doesn't happen without this. Also done for ease of editing through the Editor
func _ready() -> void:
	Particles.one_shot = true
	Particles.emitting = true
	
	Particles.material_override.albedo_color = particles_colour
	request_ready()

## Make the Particles' albedo_color update to particles_colour every frame
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		Particles.material_override.albedo_color = particles_colour

## NOTE: This is called by the Node which spawns the HitEffect!
## NOTE: (that's either the weapon itself or the projectile bullet)
## The first parameter is the position which the bullet hit
## The second parameter is the normal angle at which the Bullet hit
func draw_effect(pos: Vector3, normal: Vector3) -> void:
	## Put the effect at the right global_position where the bullet hit
	self.global_position = pos
	
	## Make the Particles emit in the same direction as the hit object's Normals
	Particles.process_material.direction = normal

## Delete this Node once it's done.
func _on_particles_finished() -> void:
	if !Engine.is_editor_hint():
		queue_free()
