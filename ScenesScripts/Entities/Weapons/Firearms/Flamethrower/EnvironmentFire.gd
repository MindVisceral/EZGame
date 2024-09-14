@tool
class_name EnvironmentFire
extends Node3D

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Particles variables")

## This Fire's overall color
@export_color_no_alpha var fire_color: Color = Color.ORANGE_RED


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Reference to this Fire's GPUParticles3D Node.
@export var fire_particles: GPUParticles3D

## Reference to the OmniLight, which lights up everything around the Fire
@export var fire_light: OmniLight3D


###-------------------------------------------------------------------------###
##### Editor-only
###-------------------------------------------------------------------------###

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		## Update fire_particles' base albedo color to the exported fire_color value
		fire_particles.draw_pass_1.material.albedo_color = fire_color
		
		## Same for the light
		fire_light.light_color = fire_color
		
	

###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

##
func _ready() -> void:
	## Make sure this Fire's fire_particles' base albedo color is set to the exported fire_color
	fire_particles.draw_pass_1.material.albedo_color = fire_color
	## Do the same for the Light's color
	fire_light.light_color = fire_color
	
	## Fire also gets bigger with time...
