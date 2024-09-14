@tool
class_name EnvironmentFire
extends Node3D

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("General Fire variables")

## How much time should pass before the Fire is fully extinguished and queue_free()-d?
## In other words, how long does this Fire last?
@export_range(0.1, 60.0, 0.1) var fire_lifetime: float = 15.0

## At which point in the Fire's lifetime should it be biggest?
## When set to 0.5, the Fire will be at its biggest at half of its lifetime - (fire_lifetime * 0.5),
## which would be (7.5 seconds) if (fire_lifetime = 15.0).
@export_range(0.01, 1.0, 0.01) var max_size_ratio: float = 0.5


@export_group("Sprite variables")

## FireSprite's maximum size - the Fire Sprite will be this big at its biggest.
## This is done by modifying its pixel_size variable, so keep this low.
## NOTE: Default is 0.01, so changing that to 0.02 doubles the sprite's size.
@export_range(0.005, 0.1, 0.001) var sprite_target_size: float = 0.035


@export_group("Particles variables")

## This Fire's overall color
@export_color_no_alpha var fire_color: Color = Color.ORANGE_RED


@export_group("OmniLight variables")

## OmniLight's maximum Range variable - the light will reach this far (in meters) at its biggest
@export_range(0.1, 10.0, 0.1) var omnilight_target_range: float = 7.0


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Reference to this Fire's Sprite3D Node.
@export var fire_sprite: Sprite3D

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
	
		## When not in the editor...
	if !Engine.is_editor_hint():
		## Create a Timer. Once it runs out,
		## this Fire is considered extinguished and subsequently queue_free()-d
		var extinguish_timer: SceneTreeTimer = get_tree().create_timer(fire_lifetime)
		extinguish_timer.timeout.connect(fire_extinguished)
		
		## Fire gets bigger with time...
		var fire_sprite_size_tween: Tween = get_tree().create_tween()
		## Fire is at its biggest at a preset point in its total lifetime
		fire_sprite_size_tween.tween_property(fire_sprite, "pixel_size", \
			sprite_target_size, (fire_lifetime * max_size_ratio) )
		## Once that tween_property is finished, start making the Fire smaller until it's gone entirely
		fire_sprite_size_tween.tween_property(fire_sprite, "pixel_size", \
			0.0, (fire_lifetime - (fire_lifetime * max_size_ratio)) )
		
		## Do the exact same thing for the OmniLight
		var fire_light_range_tween: Tween = get_tree().create_tween()
		fire_light_range_tween.tween_property(fire_light, "omni_range", \
			omnilight_target_range, (fire_lifetime * max_size_ratio) )
		fire_light_range_tween.tween_property(fire_light, "omni_range", \
			0.0, (fire_lifetime - (fire_lifetime * max_size_ratio)) )
			
		
	

## This Fire's time is over, time for it to be queue_free()-d
func fire_extinguished() -> void:
	queue_free()
