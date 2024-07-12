extends Node

## How quickly the shaking stops
var decay: float = 0.8
## Maximum shake offset in pixels
var max_offset: Vector2 = Vector2(100, 100)
## Maximum rotation of the Camera in radians (keep very low)
var max_roll: float = 0.4

## Shake strength
var trauma: float = 0.0
## Trauma exponent; "relationship between trauma and camera movement (amount = trauma * trauma)"
var trauma_power: float = 2.0




## We use a noise to get our 'random' shaking
@onready var noise = FastNoiseLite.new()
var noise_y: int = 0

## Stores the current Camera. We will shake this Camera specifically.
var current_camera: Camera3D

func _ready() -> void:
	## We randomize the RNG,
	randomize()
	## And change some noise variables
	## NOTE: Check https://auburn.github.io/FastNoiseLite/ for previews and testing
	noise.seed = randi()
	noise.frequency = 0.1
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 2
	
	current_camera = get_viewport().get_camera_3d()


func add_trauma(amount) -> void:
	trauma = min(trauma + amount, 1.0)



func _process(delta: float) -> void:
	if current_camera:
		if trauma:
			trauma = max(trauma - decay * delta, 0)
			apply_screen_shake()

func apply_screen_shake() -> void:
	var amount = pow(trauma, trauma_power)
	
	noise_y += 1
	
	current_camera.rotation.z = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	current_camera.h_offset = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	current_camera.v_offset = max_offset.y * amount * noise.get_noise_2d(noise.seed*2, noise_y)
