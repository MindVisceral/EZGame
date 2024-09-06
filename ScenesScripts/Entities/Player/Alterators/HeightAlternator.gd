class_name PlayerHeightAlternator
extends Node


@export_group("Head height")

## We only change the Head's height if this is turned on.
@export var change_head_height: bool = true

## The distance between the Head and thevery top of the Collider.
## The value of 0.2 is pretty good.
@export_range(0.0, 0.5, 0.05) var head_coll_top_dist: float = 0.2

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player



## This is ran once; when Player is _ready()
func init(player) -> void:
	self.player = player

## Makes the Player's Collider and Head change their heights over time.
func alter_collider_height(new_height: float = player.standing_height) -> void:
	
	## Create a new tween and tween player.Collider.shape.height to the provided value
	var collider_tween = get_tree().create_tween()
	collider_tween.tween_property(player.Collider.shape, "height", new_height, player.crouch_speed)
	
	## We only change the Head's height if that is turned on.
	if change_head_height == true:
		## Create a new tween for the Head
		var head_tween = get_tree().create_tween()
		
		## NOTE: We tween between Vectors, because we can't tween between position.y and a value.
		## We must Tween the Head's to its X and Z positions, because if we Tweened to a 0,
		## it would break other Head-moving operations.
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
