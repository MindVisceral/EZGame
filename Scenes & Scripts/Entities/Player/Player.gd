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
## the shorter the jump will be.
@export var gravity_multiplier: float = 0.2

## How fast the Player accelerates when falling down
## The bigger the number, the faster the fall
## NOTE: This acceleration should only be visible when falling for a long time. Keep this # low
@export var air_time_multiplier: float = 0.05

## The maximum speed the Player may reach when falling; In practise, limits air_time
## Should be about the same as stomp_strength
@export var falling_speed_limit: float = 15.0

## Player base speed
## All states use this base variable, instead modify the state's multiplier
## if you want to change movement speed.
@export var speed: float = 11.0

## Sets control in the air; the lower the number, the less control there is
## HERE: TO BE DEPRICATED - this doesn't mesh well with ULTRAKILL-like movement
@export var air_control: float = 0.3


@export_group("Footsteps")

## Maximum counter value to be computed one step
## ?????
@export var step_lengthen: float = 0.7


@export_group("Height and crouching")

## Standing Collider height in Units
@export_range(0.1, 2, 0.1) var standing_height: float = 1.6

## Crouching Collider height in Units
@export_range(0.1, 2, 0.1) var crouch_height: float = 0.8

## Time (in seconds) over which the Collider's shape is changed
@export_range(0.05, 10, 0.05) var crouch_speed: int = 0.5


@export_group("Jump")

## Jump impulse height in units. Applied once on enter()
@export var jump_height: float = 14.0


@export_group("Stomp")

## Stomp impulse in units. Applied once on enter()
## Should be around the same as falling_speed_limit
@export var stomp_strength: float = 15.0

## The maximum height the Player may jump when performing a stomp jump
## 230 meters is the limit, but setting this to (96.5 - jump_height) grants that desired height
@export var stomp_jump_height_limit: float = 96.5


@export_group("Wall-running, -jumping, -sliding")

## The vertical height of the jump from the wall
## NOTE: This is !added! to the Player's Y velocity
@export var wall_jump_height: float = 14.0

## The horizontal power of the jump away from the wall
## NOTE: This is !multiplied! by the wall's normal,
## NOTE: which is fine because the normal is always either 0 or 1
@export var wall_jump_distance: float = 17.0

## When the Player is on a wall, they fall down slower
## The lower the number, the slower they fall down.
@export var wall_sliding_deceleration: float = 0.3


@export_group("Fly")

## Speed multiplier when fly mode is activated
## HERE: Unimplemented, unused ?????
@export var fly_mode_speed_modifier: int = 2


###-------------------------------------------------------------------------###
##### Onready variables
###-------------------------------------------------------------------------###

## Player's gravity
## Same as Globals.global_gravity, but affected by the gravity_multiplier
@onready var gravity = Globals.global_gravity * gravity_multiplier

## Player's children. Check a child's Editor Description to learn what it's used for
@onready var States: PlayerStateManager = $Scripts/StateManager
@onready var Weapons: PlayerWeaponManager = $Scripts/WeaponManager
@onready var HeightAlternator: PlayerHeightAlternator = $Scripts/HeightAlternator
@onready var HeadBob: PlayerHeadbobHandler = $Scripts/HeadBob
@onready var WeaponBob: PlayerWeaponbobHandler = $Scripts/WeaponBob
@onready var InteractionManager: PlayerInteractionManager = $Scripts/InteractionManager
@onready var UIcontroller: Node = $Scripts/UIController
@onready var JumpBufferT: Timer = $Timers/JumpBufferTimer
@onready var CoyoteTimeT: Timer = $Timers/CoyoteTimeTimer
@onready var StompJumpT: Timer = $Timers/StompJumpTimer
@onready var Collider: CollisionShape3D = $Collider
@onready var FeetCollider: CollisionShape3D = $Collider/FeetCollider
@onready var WallDetection: ShapeCast3D = $Collider/WallDetectionCast
@onready var Head: Marker3D = $Collider/Head
@onready var Firearms: Marker3D = $Collider/Head/BobbingNode/Firearms
#@onready var Firearms: Marker3D = $Head/Firearms
#@onready var Firearms: Marker3D = $Firearms
## A special ShakeableCamera; this reference is used to make the Camera shake by Player scripts
@onready var PlayerCamera: ShakeableCamera = $Collider/Head/BobbingNode/PlayerCamera
@onready var InteractableCast: ShapeCast3D = $Collider/Head/BobbingNode/InteractableCast
@onready var TPMarker: Marker3D = $Collider/Head/BobbingNode/TPMarker

## Player stats
@export_group("Stats")

@export_range(0.5, 250, 0.5) var MAX_HEALTH: float = 150
@export_range(0.5, 250, 0.5) var health: float = 100
#

###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## Flags
var is_dead: bool = false
var in_air: bool = false
var on_wall: bool = false
var is_reloading: bool = false
var is_changing_weapons: bool = false
var current_weapon = null


## Direction of movement calculated from Input in a State
var direction: Vector3 = Vector3()

## How long the Player has been in the air.
## Used in gravity code in all states; the longer the time, the faster the Player falls
## But that is limited by X in Y on Z
var air_time: float = 0.0

## The distance between the point from which the Player started a stomp, and the ground they hit.
## Set in the stomp script, used in the jump script to make the very next jump after a stomp
## reach the stomp's start height.
## Limited by stomp_jump_height_limit in the jump state script on enter()
var stomp_vertical_distance: float = 0.0

## The number of walljumps that have been performed without touching the ground since it was left.
var consecutive_walljumps: int = 0

## Current counter used to calculate next step.
#var step_cycle: float = 0

## Maximum value for _step_cycle to compute a step.
#var next_step: float = 0

###-------------------------------------------------------------------------###





#HERE unneccessary
## Stores the current height
@onready var current_height: float = standing_height

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

func _unhandled_input(event: InputEvent) -> void:
	
	## Move the Head up/down and the whole Player right/left with mouse movement
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Head.rotate_x(deg_to_rad(-1 * event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg_to_rad(-1 * event.relative.x * MOUSE_SENSITIVITY))
		
		## Clamp Head's rotation. Otherwise we could turn up/down in a circle - that causes bugs
		Head.rotation_degrees.x = clamp(Head.rotation_degrees.x, -89, 89)
	
	
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
	PlayerCamera.fov = camera_FOV
	
	## Change the Camera's position to make it first or third person
	if first_person == true:
		PlayerCamera.position = Vector3.ZERO
	else:
		PlayerCamera.position = TPMarker.position
	
	## Instantly alter Collider dimensions
	Collider.shape.height = standing_height

###
func process_view_input(delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	pass
###


#region  ## Wall-running, -jumping, and -sliding

## Finds and returns the normal of the wall that is the closest to the Player;
## The walls are detected by the WallDetection S-Cast and here is decided which one is the closest.
func find_closest_wall_normal() -> Vector3:
	## We need to turn this on really quick
	WallDetection.force_shapecast_update()
	
	## The wall's normal
	var wall_normal: Vector3 = Vector3.ZERO
	
	if WallDetection.is_colliding():
		## First, we find the StaticBody wall that is the closest to the Player
		## NOTE: Since almost all walls are probably made in TrenchBroom, most of them are part
		## NOTE: of the same StaticBody. So this is a check we make just in case.
		
		## INF on our first check in the loop, because there is no bigger distance than that
		var distance_to_wall = INF
		
		## We loop through all the Walls that the WallDetection ShapeCast could find
		## to find the Wall that is the closest to the Player
		for result in WallDetection.collision_result:
			## We get this Wall's distance to the Player's origin point
			var new_distance = result.collider.global_position.distance_to(self.global_position)
			## ...and check if this distance is smaller than the last distance...
			if new_distance < distance_to_wall:
				## If so, we update these two variables
				distance_to_wall = new_distance
				## Finally, we get the normal
				wall_normal = result.normal
				
			
		
	
	return wall_normal

## Checks the dot product from the Player's velocity and the nearest wall's normal,
## returns true if the dot product is above a certain number.
func is_moving_at_wall() -> bool:
	
	## Check if the Player is pressing any buttons.
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
											"input_forwards", "input_backwards")
	
	## If the Player isn't pressing anything at the moment...
	if input_dir != Vector2.ZERO:
		
		## Prepare the nearest wall's normal for comparison
		var temp_wall_normal: Vector3 = find_closest_wall_normal()
		var wall_normal_vector2: Vector2 = Vector2(temp_wall_normal.x, temp_wall_normal.z)
		
		## Prepare the Player's velocity for comparison
		var temp_velocity: Vector2 = Vector2(velocity.x, velocity.z)
		## Must be normalized for the dot_product to be between 0 and 1
		temp_velocity = temp_velocity.normalized()
		
		## Now we calculate the dot product between Player velocity and the wall's normal
		var dot_product: float = temp_velocity.dot(wall_normal_vector2)
		
		
		## If the dot_product is over the arbitrary value of 0.11,
		## we consider the Player to be rubbing against the wall. We return true.
		if abs(dot_product) >= 0.11:
			return true
	## Otherwise, (in both cases), we return false.
	return false

#endregion

#region  ## Sound stuff

## Play the landing sound. Puthere because many states use it.
func play_landing_sound(landing_sound) -> void:
	## We play the jump sound through the AudioManager autoload
	AudioManager.play(
		AudioManager.Type.NON_POSITIONAL,
		self,
		landing_sound)
#endregion
