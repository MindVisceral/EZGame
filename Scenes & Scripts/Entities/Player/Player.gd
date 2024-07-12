class_name Player
extends CharacterBody3D

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

## Sets control in the air; the lower the number, the less control there is
@export var air_control: float = 0.3


@export_group("Footsteps")

## Maximum counter value to be computed one step
@export var step_lengthen: float = 0.7


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

## Jump impulse height in units. Applied once on enter()
@export var jump_height: float = 25


@export_group("Stomp")

## Stomp impulse in units. Applied once on enter()
@export var stomp_strength: float = 50


@export_group("Fly")

## Speed multiplier when fly mode is activated
@export var fly_mode_speed_modifier: int = 2


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## Player's gravity
@onready var gravity = Globals.global_gravity * gravity_multiplier

## Player's children. Check a child's Editor Description to learn what it's used for
@onready var States: PlayerStateManager = $Scripts/StateManager
@onready var Weapons: PlayerWeaponManager = $Scripts/WeaponManager
@onready var HeightAlternator: PlayerHeightAlternator = $Scripts/HeightAlterator
@onready var HeadBob: PlayerHeadbobHandler = $Scripts/HeadBob
@onready var WeaponBob: PlayerWeaponbobHandler = $Scripts/WeaponBob
@onready var InteractionManager: PlayerInteractionManager = $Scripts/InteractionManager
@onready var UIcontroller: Node = $Scripts/UIController
@onready var JumpBufferT: Timer = $Timers/JumpBufferTimer
@onready var Collider: CollisionShape3D = $Collider
@onready var FeetCollider: CollisionShape3D = $FeetCollider
@onready var FloorCast: RayCast3D = $FloorCast
@onready var Head: Marker3D = $Head
@onready var Firearms: Marker3D = $Head/BobbingNode/Firearms
#@onready var Firearms: Marker3D = $Head/Firearms
#@onready var Firearms: Marker3D = $Firearms
@onready var Camera: Camera3D = $Head/BobbingNode/PlayerCamera
@onready var TPMarker: Marker3D = $Head/BobbingNode/TPMarker

## Player stats
@export_group("Stats")

@export var MAX_HEALTH = 150
@export var health = 100
#

###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## Flags
var is_dead: bool = false
## HeadBob script needs this
var in_air: bool = false
var is_reloading: bool = false
var is_changing_weapons: bool = false
var current_weapon = null


## Direction of movement calculated from Input in a State
var direction: Vector3 = Vector3()

## Current counter used to calculate next step.
#var step_cycle: float = 0

## Maximum value for _step_cycle to compute a step.
#var next_step: float = 0

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
	## Passes a reference of the Player and of the Firearms node
	## to the WeaponManager, so it can find the Weapons
	Weapons.init(self, Firearms)
	HeightAlternator.init(self)
	HeadBob.init(self)
	WeaponBob.init(self)
	InteractionManager.init(self)
	#UIcontroller.init(self)
	
	
	## Apply exported variables to the Player
	apply_exported()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if is_dead:
		return
	
	## Move the Head up/down and the whole Player right/left with mouse movement
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Head.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		## Clamp Head's rotation. Otherwise we could turn up/down in a circle - that causes bugs
		Head.rotation_degrees.x = clamp(Head.rotation_degrees.x, -89, 89)

func _unhandled_input(event: InputEvent) -> void:
	States.input(event)
	Weapons.input(event)

###
func _physics_process(delta) -> void:
	
	if !is_dead:
#		process_input(delta)
		process_view_input(delta)
#		process_movement(delta)
		
		
		##States
		States.physics_process(delta)
		## Player's movement itself, dictated by the current_state in StateManager
		set_velocity(velocity)
		move_and_slide()
		velocity = velocity

func _process(delta) -> void:
	States.process(delta)


## On ready, apply exported variables like this: 
func apply_exported() -> void:
	## Change PlayerCamera's FOV to the set value
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
