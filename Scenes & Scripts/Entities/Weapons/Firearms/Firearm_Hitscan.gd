extends FirearmBase
## ^NOTE: Extends FirearmBase! Check that scene/script for more if you can't find something here!^
class_name FirearmHitscan
## ^NOTE: All Hitscan weapons depend on this Node to work!^


###-------------------------------------------------------------------------###
##### Hitscan-specific onready variables
###-------------------------------------------------------------------------###

## The Node from which the bullets originate
## NOTE: This should be the Player's First Person camera so the Player doesn't have to
## NOTE: take the weapon's position into consideration for the weapons to not hit nearby obstacles.
## NOTE: As a result, the Player must see their target to hit it.
@export var bullet_start_pos_node: Node3D

## Bullet Trail effect variables!
#
## The point from which a bullet Trail will start
@export var bullet_start_point: Marker3D

## This Node creates a Trail effect, we will instantiate one to create the effect.
@export var bullet_trail_emitter: PackedScene = \
	preload("res://Scenes & Scripts/Entities/Weapons/Effects/Base_Bullet_Trail_Emitter.tscn")

@export var shot_effect_emitter: PackedScene = \
	preload("res://Scenes & Scripts/Entities/Weapons/Effects/Base_Shot_Effect_Emitter.tscn")

@export var shot_fire_effect: PackedScene = \
	preload("res://Scenes & Scripts/Entities/Weapons/Effects/Base_Shot_Fire_Effect.tscn")

## This Node creates the Hit Effect, we will instantiate it at the bullet end hit point.
@export var hit_effect_emitter: PackedScene = \
	preload("res://Scenes & Scripts/Entities/Weapons/Effects/Base_Hit_Effect_Emitter.tscn")

## This Node creates a decal, we will instantiate it at the bullet end hit point.
@export var bullet_hole_decal: PackedScene = \
	preload("res://Scenes & Scripts/Entities/Weapons/Effects/Base_Bullet_Hole_Decal.tscn")


###-------------------------------------------------------------------------###
##### Hitscan-specific variable storage
###-------------------------------------------------------------------------###


###-------------------------------------------------------------------------###
##### Hitscan-specific Firearm functions
###-------------------------------------------------------------------------###


## NOTE: The following functions are repeated from the FirearmBase class!

## Called by the WeaponManager when this weapon is meant to be wielded by the Player
func wield_weapon() -> void:
	super.wield_weapon()
#
## Called by the WeaponManager when this weapon is meant to be put away by the Player
func put_weapon_away() -> void:
	super.put_weapon_away()


## Called when the primary_action button is pressed
func primary_action() -> void:
	super.primary_action()
	
	## Primary action fires a RayCast "bullet"
	cast_bullet_ray()
#
## Called when the secondary_action button is pressed
func secondary_action() -> void:
	super.secondary_action()



## Create a Ray in Space, which will act as a bullet for Hitscan weapons
func cast_bullet_ray() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	## Parameters of the Ray;
	#
	## Starting position of the Ray, the point from which the bullets will come out of
	var start_pos: Vector3 = bullet_start_pos_node.global_transform.origin
	## End pos of the Ray; start_pos extended towards where the Player is looking,
	## multiplied by FirearmBase @export-ed max_distance variable
	var end_pos: Vector3 = start_pos - \
		(bullet_start_pos_node.global_transform.basis.z * self.max_distance)
	#
	## NOTE: bullet_collision_mask is @exported from the FirearmBase class; change it in the editor.
	## That makes this RayCast only detects objects on the same layers as this variable.
	
	## Set the above Ray parameters
	var ray_param: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start_pos, \
		end_pos, bullet_collision_mask)
	## We want it to detect HurtBoxes (which are Areas) too, not just bodies (like the Environment)
	ray_param.collide_with_areas = true
	## Finally, cast the Ray in space_state, with ray_param as its parameters
	var result: Dictionary = space_state.intersect_ray(ray_param)
	
	## Instantiate a Shot Effect coming out of the gun's barrel,
	## This is completely independent from the bullet stuff.
	var shot_effect = shot_effect_emitter.instantiate()
	get_tree().get_root().add_child(shot_effect)
	## Set the shot_effect's transform to be the same as the bullet_start_point's
	shot_effect.draw_effect(bullet_start_point.global_transform, Color.LIGHT_GRAY)
	
	## Instantiate a Fire Shot Effect coming out of the gun's barrel,
	## This is completely independent from the bullet stuff.
	var fire_shot_effect = shot_fire_effect.instantiate()
	## NOTE: No need to set any Transforms since this effect will not be a child of root
	bullet_start_point.add_child(fire_shot_effect)
	
	
	## Instantiate a Trail, no matter if the bullet (RayCast) hit anything or not;
	## but we will check if it did soon.
	var trail = bullet_trail_emitter.instantiate()
	get_tree().get_root().add_child(trail)
	
	## Now we may check results of this Ray we just cast.
	#
	## Options 1 & 2: The "bullet" hit something and returned a result.
	if result:
		
		## Option 1: The "bullet" hit an Entity - we know that because it has a Hurtbox
		## This necessitates damage calculations an an Entity-specific hit effect
		if result.collider is Hurtbox:
			## Create a new DamageData Resource, which will be passed to the Hurtbox, which
			## will interpret it and pass on to the Entity
			var damageData = DamageData.new()
			
			## We give this Resource some data
			damageData.damage_value = default_damage
			damageData.hit_point = result.position
			
			## With DamageData's data assigned,
			## we pass this Resource on to the result.collider's Hurtbox
			result.collider.pass_DamageData(damageData)
		
		## Option 2: The "bullet" hit a part of the Environment. But we only assume that it did,
		## because there was not Hurtbox.
		## This necessitates the regular hit effect and an Environment decal
		elif result.collider:
		
			## Instantiate a decal...
			var decal = bullet_hole_decal.instantiate()
			get_tree().get_root().add_child(decal)
			## The first parameter is the point at which the Decal is drawn,
			## the second one is the result's normal;
			## we use it to make the Decak face away from the hit object
			decal.draw_decal(result.position, result.normal)
			
			## Instantiate a regular Hit Effect
			var hit_effect = hit_effect_emitter.instantiate()
			get_tree().get_root().add_child(hit_effect)
			## The first parameter is the point at which the Hit Effect is emitted,
			## the second one is the result's normal;
			## we use it to make the Particles emit at the proper angle to the hit object
			hit_effect.draw_effect(result.position, result.normal)
		
		
		## NOTE: No matter if the hit 'something' is an Entity or not, instantiate a trail.
		## The first parameter is the point at which the Trail starts,
		## the second one is where the Trail ends. In this case it's where the bullet ended up.
		trail.draw_mesh(bullet_start_point.global_position, result.position)
		
	
	## Option 3: The "bullet" has not hit anything. 
	## In this case we only instantiate the Trail. No need for any hit effects.
	else:
		## Since the Ray returned no results, the second parameter is just
		## a Vector3 somewhere way off in the distance.
		## This creates an illusion that the bullet went on beyond the Player's sight
		trail.draw_mesh(bullet_start_point.global_position, end_pos)