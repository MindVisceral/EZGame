## For usage instructions, see the YouTube video below (by Pefeper):
## https://www.youtube.com/watch?v=1i5SB8Ct1y0
class_name ShakeableCamera
extends Camera3D

## Trauma is reduced by this decay value (multiplied by delta) every frame;
## Makes the screen shake fade over time
@export var trauma_decay_rate: float = 1.0

## Maximum value the Camera may be rotated by on each axis
## Keep low for best effect
@export_range(1.0, 20.0, 0.5) var max_x: float = 10.0
@export_range(1.0, 20.0, 0.5) var max_y: float = 10.0
@export_range(1.0, 10.0, 0.5) var max_z: float = 5.0

## Random noise which the Camera will be shaken (rotated) by
@export var noise: FastNoiseLite
## How fast the Camera shakes;
## Higher number = more erratic, 'stronger' shaking
@export var noise_speed: float = 50.0

## A value to keep track of shaking;
## Add to it to increase shaking, subtract from it to decrease it.
## NOTE: This is clamped and it's always a value between 0 and 1.
var trauma = 0.0

## We must keep track of this so the Camera returns to its proper rotation.
@onready var initial_rotation: Vector3 = self.rotation_degrees


func _process(delta: float):
	## Trauma decays over time
	trauma = max(trauma - delta * trauma_decay_rate, 0.0)
	
	## We rotate the Camera by trauma^2 and by noise to get random, but smooth shaking
	self.rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	self.rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	self.rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)

## Called by nodes and scripts which want to add trauma (and thus some shaking) to the Camera
func add_trauma(trauma_amount : float):
	## The trauma is always a value between 0 and 1.
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

## We make the trauma exponentially more powerful.
func get_shake_intensity() -> float:
	return trauma * trauma

## We use random noise to make the shaking look nice.
func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	## We use the OS' time since the game has started as a simple Timer
	return noise.get_noise_1d(Time.get_ticks_msec() * noise_speed)
