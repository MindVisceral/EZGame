class_name PlayerHeightAlternator
extends Node


@export_group("Head height")

## We only change the Head's height if this is turned on.
@export var change_head_height: bool = true



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
		## Create a new tween
		var head_tween = get_tree().create_tween()
		## NOTE: We tween between Vectors, because we can't tween between position.y and a value
		## NOTE: Could cause issues if Head is supposed to move on X and/or Z axis
		var height_vector: Vector3 = Vector3(0, new_height, 0)
		
		## The Head is always 0.2 units away from the very top of the Collider
		height_vector.y = (new_height / 2) - 0.2
		## Clamped - we don't want the Head to go into the floor or to go higher than the Collider
		height_vector.y = clampf(height_vector.y, 0.2, new_height / 2)
		
		## Finally, we may Tween the Head's position
		head_tween.tween_property(player.Head, "position", height_vector, player.crouch_speed)
