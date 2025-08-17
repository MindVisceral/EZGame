class_name ProjectileBase
extends RigidBody3D


###-------------------------------------------------------------------------###
##### Exported references
###-------------------------------------------------------------------------###

@export_group("Exported references")


###-------------------------------------------------------------------------###
##### References
###-------------------------------------------------------------------------###

@export_group("References")

## Projectile's Collider
@export var collider: CollisionShape3D

## Reference to the Projectile's Hitbox
@export var hitbox_collider: CollisionShape3D

## Reference to detection Timer
@export var firing_agent_detection_timer: Timer


@export_group("PackedScenes References")

@export var hit_effect_emitter: PackedScene = \
	preload("res://ScenesScripts/Entities/Weapons/Effects/Base_Hit_Effect_Emitter.tscn")


###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Projectile variables")

## Speed at which this Projectile moves through space in direction
@export_range(0.1, 999.0, 0.1) var speed: float = 10.0

## How long the Projectile should ignore its firing_agent after being fired (in seconds)
@export_range(0.1, 999.0, 0.01) var collision_exception_time: float = 0.5

###-------------------------------------------------------------------------###
##### Regular variables
###-------------------------------------------------------------------------###

## Whatever fired this Projectile
var firing_agent: Node3D

## Direction in which this Projectile will move in
var direction: Vector3


###-------------------------------------------------------------------------###
##### Core functions
###-------------------------------------------------------------------------###

func _ready() -> void:
	
	## Set this Body's linear velocity to it's movement direction
	## Normalize the direction and make it move at 'speed' velocity.
	linear_velocity = direction.normalized() * speed
	
	## Rotate the projectile in the direction of its movement
	self.look_at(transform.origin + direction)
	
	## Whoever fired this projectile will be ignored from collisions for a moment after firing
	add_collision_exception_with(firing_agent)
	#
	## But collisions msut be turned back on after a time
	await get_tree().create_timer(collision_exception_time).timeout
	remove_collision_exception_with(firing_agent)

## By default, when the Projectile collides with something it is destroyed
func _on_collision(body: Node) -> void:
	
	## Instantiate a regular Hit Effect
	var hit_effect: HitEffectEmitter = hit_effect_emitter.instantiate()
	get_tree().get_root().add_child(hit_effect)
	hit_effect.draw_effect(self.position, Vector3.ZERO)
	
	queue_free()
