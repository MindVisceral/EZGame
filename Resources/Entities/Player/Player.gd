extends CharacterBody3D
class_name Player

###-------------------------------------------------------------------------###
##### Variables of Movement and Input
###-------------------------------------------------------------------------###

### Mouse and gamepad variables
@export_group("Mouse and Gamepad")

@export var MOUSE_SENSITIVITY = 0.05
@export var mouse_scroll_value = 0
@export var MOUSE_SENSITIVITY_SCROLL_WHEEL = 0.12


### Camera variables
@export_group("Camera")

## Default camera FOV
@export_range(5, 170, 0.1) var camera_FOV: int = 90
## Decides if the Camera is in the first person view (true), or the third person view (false)
## FP position is same as Head position, TP position is same as TPMarker's position
@export var first_person: bool = true


### Movement variables
@export_group("Base movement")

## Player Gravity Multiplier
## The higher the number, the faster the Player will fall to the ground and 
## the jump will be shorter.
@export var gravity_multiplier: float = 0.2

## Player base speed
## All states use this base variable, instead modify the multiplier
## if you want to change movement speed.
@export var speed: float = 16

#HERE unneccessary
## Time it takes for the character to reach max speed
@export var acceleration: float = 8

#HERE unneccessary
## Time for the character to stop moving
@export var deceleration: float = 10

## Sets control in the air; the lower the number, the less control there is
@export var air_control: float = 0.3


@export_group("Footsteps")

## Maximum counter value to be computed one step
@export var step_lengthen: float = 0.7

## Value to be added to compute a step, each frame that the character is walking this value 
## is added to a counter
@export var step_interval: float = 6.0


@export_group("Height and crouching")

## Default Collider height in units
@export_range(0.1, 2, 0.1) var default_height: float = 1.6

## Default Collider crouch height in units
@export_range(0.1, 2, 0.1) var crouch_height: float = 0.9


## Default Collider width in units
@export_range(0.1, 1, 0.05) var default_width: float = 0.45


## Head's default height (Y coordinate) in units
@export_range(0.1, 2, 0.1) var default_head_height: float = 1.4

## Head's default crouch height (Y coordinate) in units
@export_range(0.1, 2, 0.1) var crouch_head_height: float = 0.7


## Feet default height (Y coordinate) in units
@export_range(0.1, 1, 0.1) var default_feet_height: float = 0.2

## Feet default crouch height (Y coordinate) in units
@export_range(0.1, 1, 0.1) var crouch_feet_height: float = 0.6


## FloorCast default height (Y coordinate) in units
@export_range(0.0, 1, 0.1) var default_FloorCast_height: float = 0.0

## FloorCast default crouch height (Y coordinate) in units
@export_range(0.0, 1, 0.1) var crouch_FloorCast_height: float = 0.4

## The speed at which the Collider's shape is changed;
## bigger number == faster Collider change to standing/crouch height
@export_range(1, 70, 1) var crouch_speed: int = 12


@export_group("Jump")

## Jump height in units
@export var jump_height: float = 25


@export_group("Stomp")

## Jump height in units
@export var stomp_strength: float = 50


@export_group("Fly")

## Speed multiplier when fly mode is actived
@export var fly_mode_speed_modifier: int= 2


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## Player's gravity
@onready var gravity = Globals.global_gravity * gravity_multiplier

## Player's children. Check a child's Editor Description to learn what it's used for
@onready var States: Node = $Scripts/StateManager
@onready var UIcontroller: Node = $Scripts/UIController
@onready var HeightAlternator: Node = $Scripts/HeightAlterator
@onready var JumpBufferT: Timer = $Timers/JumpBufferTimer
@onready var Collider: CollisionShape3D = $Collider
@onready var FeetCollider: CollisionShape3D = $FeetCollider
@onready var FloorCast: RayCast3D = $FloorCast
@onready var Head: Marker3D = $Head
@onready var Camera: Camera3D = $Head/PlayerCamera
@onready var TPMarker: Marker3D = $Head/TPMarker

## Flags
var is_reloading: bool = false
var is_changing_weapons: bool = false
var is_dead: bool = false
var current_weapon = null

## Player stats
@export_group("Stats")

@export var MAX_HEALTH = 150
@export var health = 100
#

###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## Direction of movement calculated from Input
var direction: Vector3 = Vector3()

## Current counter used to calculate next step.
var step_cycle: float = 0

## Maximum value for _step_cycle to compute a step.
var next_step: float = 0

###-------------------------------------------------------------------------###


#HERE unneccessary
## Stores the current height
@onready var current_height: float = default_height

#HERE unneccessary
## Character controller horizontal speed.
var horizontal_velocity

#HERE unneccessary
## True if in the last frame it was on the ground
var _last_is_on_floor: bool = false





func _ready():
	## Passes a reference of the Player class to the states so that it can be used by them
	States.init(self)
#	UIcontroller.init(self)
	HeightAlternator.init(self)
	
	## Apply exported variables to the Player
	apply_exported()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if is_dead:
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Head.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		var camera_rot = Head.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -89, 89)
		Head.rotation_degrees = camera_rot

func _unhandled_input(event: InputEvent) -> void:
	States.input(event)

###
func _physics_process(delta) -> void:
	
	if !is_dead:
#		process_input(delta)
		process_view_input(delta)
#		process_movement(delta)
		
		##States and movement
		States.physics_process(delta)
		set_velocity(velocity)
#		set_up_direction(Vector3.UP)
		move_and_slide()
		velocity = velocity

func _process(delta) -> void:
	States.process(delta)


###
func process_input(delta):
	#Walking
	var cam_xform = Camera.get_global_transform()
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	#Still walking...
#	input_movement_vector = input_movement_vector.normalized()
	
#	direction += -cam_xform.basis.z * input_movement_vector.y
#	direction += cam_xform.basis.x * input_movement_vector.x
	#
	
	#Changing weapons
	if Input.is_action_just_pressed("weapon1"):
		current_weapon = 1
	elif Input.is_action_just_pressed("weapon2"):
		current_weapon = 2
	elif Input.is_action_just_pressed("weapon3"):
		current_weapon = 3
	#
	
	#Shooting
	if Input.is_action_pressed("primary_fire"):
		if is_changing_weapons == false:
			if current_weapon != null:
				if current_weapon.ammo_in_weapon > 0:
					pass
				else:
					is_reloading = true
	#
	
	#capturing the mouse
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#
###

###
#func process_movement(delta):
#	direction.y = 0
#	direction = direction.normalized()
#
#	velocity.y += delta * gravity_multiplier
#
#	var horizontal_velocity = velocity
#	horizontal_velocity.y = 0
#
#	var target = direction
#	if is_sprinting:
#		target *= sprint_speed_multiplier
#	else:
#		target *= speed
#
#	var accel
#	if direction.dot(horizontal_velocity) > 0:
#		if is_sprinting:
#			accel = acceleration
#		else:
#			accel = acceleration
#	else:
#		accel = deceleration
#
#	horizontal_velocity = horizontal_velocity.lerp(target, accel * delta)
#	velocity.x = horizontal_velocity.x
#	velocity.z = horizontal_velocity.z
#
#	var snap = Vector3.DOWN if not is_jumping else Vector3.ZERO
#	set_velocity(velocity)
#	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
#	set_up_direction(Vector3.UP)
#	set_floor_stop_on_slope_enabled(true)
#	set_max_slides(4)
##	set_floor_max_angle(deg_to_rad(??????????))
#	move_and_slide()
#	velocity = velocity
####


## On ready, apply exported variables like this: 
func apply_exported() -> void:
	## Change the PlayerCamera's FOV to the set value
	Camera.fov = camera_FOV
	
	## Change the Camera's position to make it first or third person
	if first_person == true:
		Camera.position = Vector3.ZERO
	else:
		Camera.position = TPMarker.position
	
	## Instantly alter Collider dimensions
	Collider.shape.height = default_height
	Collider.shape.radius = default_width
	
	## Instantly alter Head (and thus Camera) height
	Head.position.y = default_head_height

###
func process_view_input(delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
###

func check_for_floor() -> bool:
	FloorCast.force_raycast_update()
#	print(FloorCast.is_colliding())
	return FloorCast.is_colliding()
