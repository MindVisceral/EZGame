extends Firearm
## ^NOTE: Extends Firearm! Check that scene/script for more information^


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## The Node from which the bullets originate
## If the bullets are Rays, this should be the Camera (but only in first person)
@export var bullet_start_pos_node: Node3D

## The point from which a bullet Trace will start
@onready var bullet_start_point := $ModelHolder/gun1/Armature/Base_bone/Grip1/TraceSpawnPoint
## We will instantiate this Node to make a line between the gun and the point the gun has shot at
@onready var bullet_trail_emmiter: PackedScene = preload("res://Resources/Entities/Weapons/Bullet_Trail_Emmiter.tscn")



###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###




func _physics_process(delta: float) -> void:
	pass


## Called by the WeaponManager when this weapon is meant to be wielded/put away by the Player
func wield_weapon() -> void:
	super.wield_weapon()
#
func put_weapon_away() -> void:
	super.put_weapon_away()


## Called by the WeaponManager when the primary_action or the secondary_action buttons are pressed
func primary_action() -> void:
	super.primary_action()
	cast_bullet_ray()
#
func secondary_action() -> void:
	super.secondary_action()



## #HERE - Could be remade into bullet holes. LATER
var decal_insta = preload("res://test_decal.tscn")



## Create a Ray in Space, which will act as a bullet for this RayCast-type weapon
func cast_bullet_ray() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	## Parameters of the Ray;
	#
	## Starting position of the Ray, the point from which the bullets will come out of
	var start_pos: Vector3 = bullet_start_pos_node.global_transform.origin
	## End pos of the Ray; start_pos extended towards where the Player is looking,
	## multiplied by the weapon's exported max_distance variable
	var end_pos: Vector3 = start_pos - bullet_start_pos_node.global_transform.basis.z * self.max_distance
	#
	## bullet_collision_layer is @exported; it's set in editor. It's in the Firearm script
	
	## Set Ray parameters; they are above this comment
	var ray_param: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start_pos, \
		end_pos, self.bullet_collision_layer)
	## Cast the Ray itself in space_state, with ray_param as its parameters
	var result = space_state.intersect_ray(ray_param)
	
	## Check results
	## #HERE - do damage calcualtions, then hitting the environment, then not hitting anything
	if result:
#		print(result)
		## Test decal to check for collision
		var decal = decal_insta.instantiate()
		get_tree().get_root().add_child(decal)
		decal.position = result.position
		
	else:
		print("shot nothing!")
	
	## Either way, instantiate a trail
	var trail = bullet_trail_emmiter.instantiate()
	get_tree().get_root().add_child(trail)
	
	## This first variable is the trail's global_position and start_pos,
	## the second one is where the trail will end up after some time
	trail.init(bullet_start_point.global_position, end_pos)
	
	
#	print("Start position: ", trail.start_position)
#	print("Global position: ", trail.global_position)
#	print("End position: ", trail.end_position)
	
	
	
	
	
