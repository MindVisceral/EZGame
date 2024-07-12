extends Node3D

## This Timer will lead to queue_free() once it runs out
@onready var timer: Timer = $Timer

## 
var velocity: Vector3

## The starting position of this Trail
var start_position: Vector3
## The final position of this Trail. It will be deleted once it reaches it
var end_position: Vector3


## We calculate how long it will take this Node until it reaches end_position
var time_until_arrival

func init(start_pos, end_pos) -> void:
	self.global_position = start_pos
	self.start_position = start_pos
	self.end_position = end_pos
	
	## Make the trail face towards the end_position
	## NOTE: The particle node is rotated on the X axis to make its cyllinders point the right way
	look_at(self.global_transform.origin + end_position, Vector3.UP)

## When this Node is instatianted, it will move from start_position to end_position
## to simulate a bullet coming out of a gun
func _physics_process(delta: float) -> void:
#	time_until_arrival
	
#	velocity = end_position - start_position
#	self.global_position += velocity * delta * 0.0005	##0.01
	
	self.global_position += (end_position - start_position) * delta * 0.0005	##0.01

## This is a safeguard in case the Trail has been travelling for too long; deletes it
func _on_timer_timeout() -> void:
	print(" DELETED ")
	queue_free()
