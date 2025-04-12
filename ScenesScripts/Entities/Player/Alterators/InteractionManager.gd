class_name PlayerInteractionManager
extends Node


###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player
## Reference to the Player's Camera. Required for my reimplementation of ray_picking
## (which was neccessary because some twat made MOUSE_MODE_CAPTURED disable ray_picking. Fuck you.)
var camera: Camera3D



## All the Interactable nodes within Player's reach (reach is set in each Interactable separately)
var interactables: Array[Interactable] = []

var closest_interactable: Interactable = null

###-------------------------------------------------------------------------###
##### Exported variables
###-------------------------------------------------------------------------###

@export_group("Variables")

## Range of the InteractableCast in meters
@export var InteractableCast_range: float = 1

## The Node from which the ray originates
## Should be the Camera
@export var ray_start_pos_node: Node3D

## Layers which the interaction ray can see, so pretty much just the Interactable layer
## Only made an exported variable to avoid headaches with hard-coded layers
@export_flags_3d_physics var ray_collision_mask = 32

###-------------------------------------------------------------------------###
##### Setup functions
###-------------------------------------------------------------------------###

## This Node needs a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	self.player = player

###-------------------------------------------------------------------------###
##### Executing functions
###-------------------------------------------------------------------------###

func _process(delta: float) -> void:
	## Reset the closest_interactable, we find a new one every single frame, unfortunately
	if closest_interactable != null:
		closest_interactable.unfocused.emit()
		closest_interactable = null
	
	## Fire the InteractableCast, check if it collided with any Interactables
	if player.InteractableCast.is_colliding():
		## Now we will find the closest Interactable among the Interactables that
		## the InteractableCast managed to find
		
		
		var collision_point: Vector3 = player.InteractableCast.get_collision_point(0)
		
		## We make a new Array that holds all the Ineractables we will be considering
		var found_interactables: Array
		for found_interactable in player.InteractableCast.collision_result:
			found_interactables.append(found_interactable.collider)
		
		## And we pass that Array to the find_closest_interactable() function, which
		## will find the closest Interactable!
		closest_interactable = find_closest_interactable(found_interactables, collision_point)
		
		closest_interactable.focused.emit()
		## When the Player wants to interact with something...
		if Input.is_action_just_pressed("input_interact"):
				## We simply interact with that closest Interactable
				closest_interactable.interact.emit()


## Finds the Interactable which is the nearest to the Player
## (but only if it has been detected by InteractableCast)
func find_closest_interactable(found_interactables_array: Array, \
								collision_point: Vector3) -> Interactable:
	
	## INF on our first check in the loop, because there is no bigger distance than that
	var distance_to_interactable = INF
	## I left this at Null, because we know that there is a closest Interactable somewhere,
	## because this function wouldn't be called otherwise.
	var closest_interactable: Interactable
	
	## We loop through all the Interactables that the InteractableCast could find
	## to find the Interactable that is the closest to the Player
	for item in found_interactables_array:
		## We get this Interactable's distance to the InteractableCast's
		## collision point with an Interactable.
		var new_distance = item.global_position.distance_to(collision_point)
		## ...and check if this distance is smaller than the last distance...
		if new_distance < distance_to_interactable:
			## If so, we update these two variables
			distance_to_interactable = new_distance
			closest_interactable = item
		
	
	## Now that we are sure which Interactable is the closest, we simply return it
	return closest_interactable
