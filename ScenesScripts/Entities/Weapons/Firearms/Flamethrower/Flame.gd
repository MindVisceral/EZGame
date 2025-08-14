@tool
class_name FireBullet
extends ProjectileBase


###-------------------------------------------------------------------------###
##### Exported references
###-------------------------------------------------------------------------###

@export_group("Exported references")

## Reference to the Environmental Fire scene. Instantiated when the Environment is hit.
@export var environment_fire: PackedScene


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Reference to this Fire's Sprite3D Node.
@export var flame_sprite: Sprite3D

## Reference to this Fire's GPUParticles3D Node.
@export var flame_particles: GPUParticles3D

## Reference to the OmniLight, which lights up everything around the Fire
@export var flame_light: OmniLight3D


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Flame visuals")

## This Flame's overall color
@export_color_no_alpha var flame_color: Color = Color.ORANGE_RED


@export_group("Sprite size")

## How big should the Flame's Sprite be by the time the Flame is at its biggest?
## (in meters/pixel size); keep at a very low number
@export_range(0.001, 1.0, 0.001) var max_sprite_size: float = 0.03

## How much time must pass until the Flame's Sprite is at its biggest?
## (in seconds)
@export_range(0.1, 50.0, 0.1) var time_until_max_sprite_size: float = 1.5


@export_group("Collider size")

## How big should the Flame's Collider be by the time the Flame is at its biggest?
## (in meters)
@export_range(0.1, 999.0, 0.1) var max_collider_size: float = 0.4

## How much time must pass until the Flame's Collider is at its biggest?
## (in seconds)
@export_range(0.1, 50.0, 0.1) var time_until_max_collider_size: float = 2.5


@export_group("Hitbox Collider size")

## How big should the Flame's Hitbox's Collider be by the time the Flame is at its biggest?
## (in meters)
@export_range(0.1, 999.0, 0.1) var max_hitbox_size: float = 0.8

## How much time must pass until the Flame's Hitbox's Collider is at its biggest?
## (in seconds)
@export_range(0.1, 50.0, 0.1) var time_until_max_hitbox_size: float = 3.5


###-------------------------------------------------------------------------###
##### Editor-only
###-------------------------------------------------------------------------###

##
func _process(delta: float) -> void:
	## Only matters when in the Editor.
	if Engine.is_editor_hint():
		## Update fire_particles' base albedo color to the exported flame_color value
		flame_particles.draw_pass_1.material.albedo_color = flame_color
		
		## Same for the light
		flame_light.light_color = flame_color
		
	


###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	## We only do the following when not in the Editor!
	if !Engine.is_editor_hint():
		## Set this Body's linear velocity to direction set by the Firearm it was fired from.
		## Normalize the direction and make it move at 'speed' velocity.
		linear_velocity = direction.normalized() * speed
		
		## The Fire's Sprite, Hitbox, and Collider sizes should increase over time,
		## because IRL fire burns through the fluid and the flames rise with heat;
		## in result, the Flame gets bigger with time.
		#
		## Just the Sprite size
		var sprite_tween: Tween = get_tree().create_tween()
		sprite_tween.tween_property(self.flame_sprite, "pixel_size", \
			max_sprite_size, time_until_max_sprite_size)
			
		#
		## Just the RigidBody Collider
		var collider_tween: Tween = get_tree().create_tween()
		collider_tween.tween_property(self.collider.shape, "radius", \
			max_collider_size, time_until_max_collider_size)
			
		#
		## Hitbox's Collider's size
		var hitbox_tween: Tween = get_tree().create_tween()
		hitbox_tween.tween_property(self.hitbox_collider.shape, "radius", \
			max_hitbox_size, time_until_max_hitbox_size)
			
		
	

## When this Flame "Bullet" collides with something, it's destroyed.
## Depending on what it hits, it will behave differently;
## it hits the Environment - spawns a Fire, Entity - sets it on fire
func _on_collision(body: Node) -> void:
	## HERE: Only if the Environment was hit! - Entity collision not implemented
	## Instantiate Environmental Fire.
	var fire_instance: EnvironmentFire = environment_fire.instantiate()
	## We use this Flame's global_position as the Fire's global_position;
	## this could cause problems if the Flame's Collider is too large - the Fire could
	## be too far from the collision point to make sense.
	## NOTE: Finding the collision point would be the correct practise here, but alas...
	fire_instance.global_position = self.global_position
	get_tree().get_root().add_child(fire_instance)
	
	queue_free()
