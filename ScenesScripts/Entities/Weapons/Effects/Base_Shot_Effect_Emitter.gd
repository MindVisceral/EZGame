@tool
extends Node3D
## NOTE: This Node is queue_free()-d when the Particles Node is finished


## This GPUParticles3D Node is all that this Shot Effect really is
@onready var Particles: GPUParticles3D = $SmokeParticles

## Colour of the particles.
@export var particle_colour: Color = Color.WHITE


## The Effect just doesn't happen without this
func _ready() -> void:
	## When outside the editor, run the particles
	if !Engine.is_editor_hint():
		Particles.one_shot = true
		Particles.emitting = true
	
	## Change the particles colour to @exported particle_colour variable when _ready()
	## This might be unnecessary since draw_effect() function also does this.
	Particles.process_material.color = particle_colour


func _process(delta: float) -> void:
	## Change the particles' colour to @exported particle_colour variable while in the Editor
	if Engine.is_editor_hint():
		Particles.process_material.color = particle_colour


## NOTE: This is called by the Node which spawns the ShotEffect, which is the weapon probably.
## The first parameter is used to transform this Emitter so that the Effect at the same location as
## the gun's barrel and it has the same rotation.
## The second parameter changes the Effect's colour. Remains particle_colour if not specified.
func draw_effect(global_transform_value: Transform3D, \
		colour_value: Color = particle_colour) -> void:
	
	## Apply provided transform to self
	self.global_transform = global_transform_value
	
	## Change the particles' colour to provided colour_value
	Particles.process_material.color = colour_value

## Delete this Node once it's done.
func _on_smoke_particles_finished() -> void:
	## Only queue_free() while in game to avoid crashes in-Editor
	if !Engine.is_editor_hint():
		queue_free()
