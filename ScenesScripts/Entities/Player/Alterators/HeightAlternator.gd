class_name PlayerHeightAlternator
extends Node


@export_group("Head height")

## We only change the Head's height if this is turned on.
@export var change_head_height: bool = true

## The distance between the Head and the very top of the Collider.
## The value of 0.2 is pretty good.
@export_range(0.0, 0.5, 0.05) var head_coll_top_dist: float = 0.2


@export_group("Stair snapping casts heights")

## The distance between the (StairsAheadRayCast & StairsBelowRayCast)s'
## and the very bottom of the Collider.
## The values aren't precise, just guesses.
@export_range(0.0, 10, 0.05) var ahead_cast_bot_dist: float = 0.2
@export_range(0.0, 10, 0.05) var below_cast_bot_dist: float = 0.2


## Reference to the Player, so its functions and variables can be accessed directly
var player: Player


## Runs when Player is _ready()
func init(player) -> void:
	self.player = player

## Makes the Player's Collider and Head change their heights over time.
func alter_collider_height(new_height: float = player.standing_height) -> void:
	
	## Create a new tween and tween player.Collider.shape.height to the provided value
	var collider_tween := get_tree().create_tween()
	collider_tween.tween_property(player.Collider.shape, "height", new_height, player.crouch_speed)
	
	alter_snapping_casts_heights(new_height)
	
	## We only change the Head's height if that option is enabled.
	if change_head_height == true:
		## Create a new tween for the Head
		var head_tween := get_tree().create_tween()
		
		## NOTE: We tween between Vectors, because we can't tween between position.y and a value.
		## We must Tween the Head's to its X and Z positions, because if we Tweened to a 0,
		## it would break other Head-moving operations like bobbing
		var head_position: Vector3 = player.Head.position
		var height_vector: Vector3 = Vector3(head_position.x, 0, head_position.z)
		
		## Now we can modify the Head's Y position.
		## The Head is always 'head_coll_top_dist' units away from the very top of the Collider
		height_vector.y = (new_height / 2) - head_coll_top_dist
		## Clamped - we don't want the Head to go into the floor or to go higher than the Collider.
		## We use 'head_coll_top_dist', but the lower (away from the floor) limit could be distinct
		height_vector.y = clampf(height_vector.y, head_coll_top_dist, new_height / 2)
		
		## Finally, we may Tween the Head's position
		head_tween.tween_property(player.Head, "position", height_vector, player.crouch_speed)

## Vertical positions of both snapping casts must also be moved
## for snapping to work correctly when Player height is altered.
## They are both parented to %Feet Marker3D Node
func alter_snapping_casts_heights(new_height: float) -> void:
	## Tween
	var feet_tween := get_tree().create_tween()
	## Original positon
	var feet_tween_position: Vector3 = %Feet.position
	## New position vector
	var feet_height_vector: Vector3 = Vector3(feet_tween_position.x, 0, feet_tween_position.z)
	feet_height_vector.y = -(new_height / 2)
	## Finally, tween the position
	feet_tween.tween_property(%Feet, "position", feet_height_vector, player.crouch_speed)
