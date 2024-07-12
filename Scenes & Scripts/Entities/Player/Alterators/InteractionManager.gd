class_name PlayerInteractionManager
extends Node


###-------------------------------------------------------------------------###
##### Variables and references
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player

## All the Interactable nodes within Player's reach (reach is set in each Interactable separately)
var interactables: Array[Interactable] = []


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

func _physics_process(delta: float) -> void:
	
#region No Interactables in range
	## If there are no Interactables within range, we turn off the InteractableCast for efficiency
	if interactables.size() == 0:
		player.InteractableCast.enabled = false
#endregion
	
#region One Interactable within range
	## Otherwise, we turn it on and...
	elif interactables.size() == 1:
		player.InteractableCast.enabled = true
		
		## ...check if the InteractableCast intersects with that one Interactable
		player.InteractableCast.force_shapecast_update()
		if player.InteractableCast.is_colliding():
			
			## Since it does, we tell this Interactable to emit the "focused" signal
			interactables[0].focused.emit()
			
			## If the Player wants to, they may interact with this Interactable
			if Input.is_action_just_pressed("interact"):
				player.InteractableCast.get_collider(0).interact.emit()
			
		
		## Since it doesn't, we tell this Interactable to emit the "unfocused" signal
		else:
			interactables[0].unfocused.emit()
			## The Interactable becomes "unfocused" if the Player exits its range too
			## (that is written into the Interactable code itself)
#endregion
	
#region Two or more Interactables are within range
	## Here, we also turn on the InteractableCast and...
	elif interactables.size() >= 2:
		player.InteractableCast.enabled = true
		## ...check if the InteractableCast intersects with at least one of those Interactables
		player.InteractableCast.force_shapecast_update()
		if player.InteractableCast.is_colliding():
			
			## Since there is more than one Interactable within range,
			## we check which one that is the closest to the Player...
			var closest_interactable = find_closest_interactable()
			## ...unfocus all of them...
			for interactable in interactables:
				interactable.unfocused.emit()
			## ...and finally, focus only on the closest Interactable
			closest_interactable.focused.emit()
			
			## And if the Player wants to, they may interact with this Interactable
			if Input.is_action_just_pressed("interact"):
				closest_interactable.interact.emit()
			
		
		## If it isn't colliding, we unfocus all the Interactables
		else:
			for interactable in interactables:
				interactable.unfocused.emit()
			## An Interactables becomes "unfocused" if the Player exits its range too
			## (that is written into the Interactable code itself)
#endregion


## Finds the Interactable which is the nearest to the Player
## (but only if it has been detected by InteractableCast)
func find_closest_interactable() -> Interactable:
	
	## INF on our first check in the loop, because there is no bigger distance than that
	var distance_to_interactable = INF
	## I left this at Null, because we know that there is a closest Interactable somewhere
	## If we couldn't be absolutely sure of that, as we are here, this would have to be different
	var closest_interactable: Interactable
	
	## We loop through all the results in InteractableCast's collision_result
	## to find the collider (Interactable) that is the closest to the Player
	for result in player.InteractableCast.collision_result:
		## We get this Interactable's distance to the Player...
		var new_distance = result.collider.global_position.distance_to(player.global_position)
		## ...and check if this distance is smaller than the last distance...
		if new_distance < distance_to_interactable:
			## If so, we update these two variables
			distance_to_interactable = new_distance
			closest_interactable = result.collider
		
	
	## Now that we are sure which Interactable is the closest, we simply return it
	return closest_interactable
