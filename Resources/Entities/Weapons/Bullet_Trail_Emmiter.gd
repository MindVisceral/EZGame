extends Node3D

## This Timer will lead to queue_free() once it runs out of time
@onready var timer: Timer = $Timer

## This Sprite3D is, essentailly, our whole Trail. We simply stretch it to the desired length.
@onready var TrailSprite: Sprite3D = $TrailSprite

## Changes the region_rect's height (size.y) variable; makes the Trail bigger or smaller
@export_range(1, 128, 1) var trail_height: int = 16


func _ready() -> void:
	## region_rect's "size.y" is just the Sprite3D's height
	TrailSprite.region_rect.size.y = trail_height



## The first variable is, typically, the gun's barrel; the Trail originates here
## The second variable is, typically, position which the RayCast bullet hit; the Trail ends here
func draw_trail(start_pos: Vector3, end_pos: Vector3) -> void:
	## Put the whole trail at the start_pos; now it will originate from this point in the world
	self.global_position = start_pos
	
	## We want the Sprite3D's offset to be half of the region_rect's height (size.y).
	## Thanks to this, we can easily change the height of the Trail (through trail_height),
	## and the Trail will always come out at the right place
	TrailSprite.offset.y = -(trail_height / 2)
	
	## We use the same principle to stretch the Sprite3D between the start and end positions
	#
	## #NOTE: "* 100", because 1px is 0.01 meters. Could be tweaked with pixel_size,
	## but that breaks the texture (makes it scale up???)
	TrailSprite.region_rect.size.x = start_pos.distance_to(end_pos) * 100
	
	## Make the whole TrailEmmiter face towards the end_position
	## #NOTE: The Sprite3D is rotated on the Y axis to make it point the right way
	self.look_at(end_pos, Vector3.UP)


## Kill the Trail once its "animation" is finished
func _on_timer_timeout() -> void:
	print(" DELETED ")
	queue_free()
