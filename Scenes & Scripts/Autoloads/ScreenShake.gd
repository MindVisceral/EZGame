extends Node

## This Autoload script causes screenshake by offsetting the currently used camera with a noise.
## To cause screenshake simply call ScreenShake.add_trauma(X) anywhere in any script.


## How quickly the shaking stops
var decay: float = 0.8
## Maximum shake offset in pixels
var max_offset: Vector2 = Vector2(100, 100)
## Maximum rotation of the Camera in radians (keep very low)
#var max_roll: float = 0.4

## Shake strength - a value is passed with add_trauma()
var trauma: float = 0.0
## Trauma exponent; "relationship between trauma and camera movement (amount = trauma * trauma)"
## This is changed by the add_trauma function - otherwise, it is 1.0 and has no effect;
## power of 2 or 3 is best
var trauma_power: float = 1.0


## We use a noise to get our 'random' shaking
@onready var noise = FastNoiseLite.new()
## We will scroll through the noise vertically
var noise_y: int = 0

## Stores the current Camera. We will shake this Camera specifically.
var current_camera: Camera3D


func _ready() -> void:
	## We randomize the RNG to get a new random noise seed
	randomize()
	## And now we change some noise variables
	## NOTE: Check https://auburn.github.io/FastNoiseLite/ for previews and testing
	noise.seed = randi_range(1, 3)
	noise.frequency = 0.8
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 2
	
	## Set current Camera - we do this on every screenshake too, just to be sure
	current_camera = get_viewport().get_camera_3d()


## This function is used to cause screen shake
func add_trauma(amount, power: float = 1.0) -> void:
	## Set the current camera
	current_camera = get_viewport().get_camera_3d()
	
	## We add 'amount' to the trauma and clamp it.
	trauma = min(trauma + amount, 1.0)
	trauma = clampf(trauma, 0.0, 1.0)
	
	## Making the trauma stronger is optional
	trauma_power = power

## Screen shake is applied every process frame, unless there is no Camera
func _process(delta: float) -> void:
	if current_camera:
		if trauma > 0:
			## The trauma decays over time, making the screen shake fade away
			trauma = max(trauma - decay * delta, 0)
			apply_screen_shake()

## Actually applies screen shake to the camera
func apply_screen_shake() -> void:
	## We take the trauma to the power of trauma_power (which is 1.0 by default)
	var amount = pow(trauma, trauma_power)
	
	## We scroll through the noise vertically
	noise_y += 1
	## And now we apply trauma to the camera's offsets
	#current_camera.rotation.z = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	current_camera.h_offset = max_offset.x * amount * noise.get_noise_2d(noise.seed, noise_y)
	current_camera.v_offset = max_offset.y * amount * noise.get_noise_2d(noise.seed, noise_y)
