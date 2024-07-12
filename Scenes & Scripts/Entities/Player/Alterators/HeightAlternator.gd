class_name PlayerHeightAlternator
extends Node


## Reference to the Player, so its functions and variables can be accessed directly
var player: Player

## This is ran once; when Player is _ready()
func init(player) -> void:
	self.player = player

## Makes the Player's Collider change its height over time.
func alter_collider_height(new_height: float = player.standing_height) -> void:
	
	## Create a new tween and tween player.Collider.shape.height to the provided value
	var tween = get_tree().create_tween()
	tween.tween_property(player.Collider.shape, "height", new_height, player.crouch_speed)
