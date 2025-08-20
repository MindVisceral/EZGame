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
@export var gravity_multiplier: float = 1.0

## The maximum speed the Player may reach when falling
## Negative, because the Player's velocity.y is negative when falling.
@export_range(-100, 0, 0.1) var falling_speed_limit: float = -50.0

## Player base speed
## All states use this base variable, instead modify the state's multiplier
## if you want to change movement speed.
@export_range(1.0, 20.0, 0.1) var speed: float = 10.0

## Sets control in the air; the lower the number, the less control there is
## HERE: TO BE DEPRICATED - this doesn't mesh well with ULTRAKILL-like movement
@export var air_control: float = 0.3


### Stairs movement variables
@export_group("Stairs movement")

## Maximum step height
## When the Player wants to move up a surface, this variable determines how high that surface
## may be before it becomes unstepable;
## the Player won't be snapped up a surface if it's higher than this number
@export var MAX_STEP_HEIGHT: float = 0.5

## Turn camera smoothing during stairs snapping on or off
## Makes the Camera lag behind the Player a bit to smooth out the Player's motions when snapping
## up or down the stairs
@export var camera_smoothing: bool = true


### Head bob footsteps????? not head bob?
@export_group("Footsteps")

## Maximum counter value to be computed one step
## ?????
@export var step_lengthen: float = 0.7


@export_group("Height and crouching")

## Standing Collider height in Units
@export_range(0.1, 2, 0.01) var standing_height: float = 1.6

## Crouching Collider height in Units
@export_range(0.1, 2, 0.01) var crouch_height: float = 0.55

## Time (in seconds) over which the Collider's shape is changed
@export_range(0.05, 10, 0.05) var crouch_speed: float = 0.15


@export_group("Jump")

## Jump impulse height in units. Applied once on enter()
@export_range(1.0, 24.0, 0.1) var jump_height: float = 7.0

## The maximum speed the Player may reach when jumping
## Used in stomp-boosted jumping code
@export_range(0, 100, 0.1) var jump_speed_limit: float = 80.0


@export_group("Stomp")

## Stomp speed in meters per second - it's always constant. Applied once on enter()
@export_range(-100, 0, 0.1) var stomp_speed: float = -50.0

## The maximum height the Player may reach when performing a stomp-boosted jump
@export var stomp_jump_height_limit: float = 115.0


@export_group("Wall-running, -jumping, -sliding")

## The vertical height of the jump from the wall
## NOTE: This is !added! to the Player's Y velocity
@export_range(1.0, 20.0, 0.1) var wall_jump_height: float = 10.0

## The horizontal power of the jump away from the wall
## NOTE: The wall's normal is !multiplied! by this!
## NOTE: ...which is fine because the normal is always either 0 or 1
@export_range(1.0, 20.0, 0.1) var wall_jump_distance: float = 12.0

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
@onready var StatusEffects: PlayerStatusEffectManager = $Scripts/StatusEffectManager
@onready var Weapons: PlayerWeaponManager = $Scripts/WeaponManager
@onready var HeightAlternator: PlayerHeightAlternator = $Scripts/HeightAlternator
@onready var HeadBob: PlayerHeadbobHandler = $Scripts/HeadBob
@onready var WeaponBob: PlayerWeaponbobHandler = $Scripts/WeaponBob
@onready var InteractionManager: PlayerInteractionManager = $Scripts/InteractionManager
@onready var UImanager: UIManager = $Scripts/UIManager
@onready var DashCooldownT: Timer = $Timers/DashCooldownTimer
@onready var JumpBufferT: Timer = $Timers/JumpBufferTimer
@onready var CoyoteTimeT: Timer = $Timers/CoyoteTimeTimer
@onready var StompJumpT: Timer = $Timers/StompJumpTimer
@onready var Collider: CollisionShape3D = $Collider
@onready var FeetCollider: CollisionShape3D = $Collider/FeetCollider
@onready var WallDetection: ShapeCast3D = $Collider/WallDetectionCast
@onready var Head: Marker3D = $Collider/Head
@onready var Firearms: Marker3D = $Collider/Head/CameraSmoothing/BobbingNode/Firearms
#@onready var Firearms: Marker3D = $Head/Firearms
#@onready var Firearms: Marker3D = $Firearms
@onready var InteractableCast: ShapeCast3D = $Collider/Head/CameraSmoothing/BobbingNode/InteractableCast
@onready var TPMarker: Marker3D = $Collider/Head/CameraSmoothing/BobbingNode/TPMarker

## Player stats
@export_group("Stats")

@export_range(0.5, 250, 0.5) var MAX_HEALTH: float = 150
@export_range(0.5, 250, 0.5) var health: float = 100
#

###-------------------------------------------------------------------------###
##### Variable storage
###-------------------------------------------------------------------------###

## Flags
#
var is_dead: bool = false
var in_air: bool = false
var on_wall: bool = false
var headbob_active: bool = true
## HERE: Old flags to be removed or reintegrated
var is_reloading: bool = false
var is_changing_weapons: bool = false
## ^^^
var current_weapon = null


## Direction of movement calculated from Input in a State
var direction: Vector3 = Vector3()

## Whether or not the Player snapped down to the stairs on the previous frame
var _snapped_to_stairs_last_frame: bool = false
## The number of the frame (since the Engine started counting)
## at which the Player was most recently on floor
var _last_frame_was_on_floor: int = -INF

## How long the Player has been in the air.
## Used in the Stomp state to determine camera shake strength. Longer in air = stronger shake.
var air_time: float = 0.0

## The distance between the point from which the Player started a stomp, and the ground they hit.
## Set in the stomp script, used in the jump script to make the very next jump after a stomp
## reach the stomp's start height. Unfortunately, has to be stored here.
## Limited by stomp_jump_height_limit in the jump state script on enter()
var stomp_vertical_distance: float = 0.0

## The number of walljumps that have been performed without touching the ground since it was left.
var consecutive_walljumps: int = 0

## Current counter used to calculate next step.
#var step_cycle: float = 0

## Maximum value for _step_cycle to compute a step.
#var next_step: float = 0

###-------------------------------------------------------------------------###


func _ready():
	## Passes a reference of the Player class to the states so that it can be used by them
	States.init(self)
	StatusEffects.init(self)
	## Passes a reference of the Player and of the Firearms node
	## to the WeaponManager, so it can find the Weapons
	Weapons.init(self, Firearms)
	HeightAlternator.init(self)
	HeadBob.init(self)
	WeaponBob.init(self)
	InteractionManager.init(self)
	UImanager.init(self)
	
	
	## Apply exported variables to the Player
	apply_exported()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if is_dead:
		return
		
	

func _unhandled_input(event: InputEvent) -> void:
	
	## Move the Head up/down and the whole Player right/left with mouse movement
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		## Up/Down
		Head.rotate_x(deg_to_rad(-1 * event.relative.y * MOUSE_SENSITIVITY))
		## Left/Right
		self.rotate_y(deg_to_rad(-1 * event.relative.x * MOUSE_SENSITIVITY))
		
		## Clamp Head's rotation. Otherwise we could turn up/down in a circle - that causes bugs
		Head.rotation_degrees.x = clamp(Head.rotation_degrees.x, -89, 89)
		
	
	States.input(event)
	Weapons.input(event)
	
	if Input.is_action_just_pressed("input_test_button"):
		self.rotation.y = PI
	

###
func _physics_process(delta: float) -> void:
	if !is_dead:
#		process_input(delta)
		process_view_input(delta)
#		process_movement(delta)
		
		## If the Player is on floor this frame, record the frame number;
		## used for stair snapping
		if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
		
		
		##States
		States.physics_process(delta)
		
		
		## Player's movement itself, dictated by the current_state in StateManager
		set_velocity(velocity)
		
		## Attempt to snap the Player up the stairs - if that fails, proceed normally
		if (not _snap_up_to_stairs_check(delta)):
			move_and_slide()
			## Check if the Player should snap down the stairs and do that if necessary
			_snap_down_to_stairs_check()
			
		velocity = velocity
		
	

func _process(delta: float) -> void:
	States.process(delta)
	


## On ready, apply exported variables like this: 
func apply_exported() -> void:
	## Change PlayerCamera's FOV to the set value
	%PlayerCamera.fov = camera_FOV
	
	## Change the Camera's position to make it first or third person
	if first_person == true:
		%PlayerCamera.position = Vector3.ZERO
	else:
		%PlayerCamera.position = TPMarker.position
		
	
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
		## NOTE: Since almost all walls are (probably) made in TrenchBroom, most of them are part
		## NOTE: of the same StaticBody. So this is a check we make just in case.
		
		## INF on our first check in the loop, because there is no bigger distance than that
		var distance_to_wall = INF
		
		## We loop through all the Walls that the WallDetection ShapeCast could find
		## to find the Wall that is the closest to the Player
		for result in WallDetection.collision_result:
			## We get the distance between this wall's collision point and the Player's origin point
			var new_distance = result.point.distance_to(self.global_position)
			## ...and check if this distance is smaller than the last distance...
			if new_distance < distance_to_wall:
				## If so, we update these two variables
				distance_to_wall = new_distance
				## Finally, we get the normal
				wall_normal = result.normal
				
			
		
	
	return wall_normal

## Checks the dot product from the Player's velocity and the nearest wall's normal,
## returns true if the dot product is above a certain number.
#
## process_input is here, because different states expect different results from this function
## If the dot_product is below dot_product_value, the Player is not moving at a wall.
func is_moving_at_wall(process_input: bool = true, dot_product_value: float = 0.11) -> bool:
	
	## Check if the Player is pressing any horizontal input keys.
	var input_dir: Vector2 = Input.get_vector("input_left", "input_right", \
		"input_forwards", "input_backwards")
	
	## If it doesn't matter if the Player is pressing anything, just proceed.
	if (process_input == false) or \
			## But if the Player must be pressing something for this to work,
			## only proceed if process_input is TRUE
			(process_input == true and !input_dir.is_zero_approx()):
		
		## Prepare the nearest wall's normal for comparison
		var temp_wall_normal: Vector3 = find_closest_wall_normal()
		var wall_normal_vector2: Vector2 = Vector2(temp_wall_normal.x, temp_wall_normal.z)
		
		## Prepare the Player's velocity for comparison
		var temp_velocity: Vector2 = Vector2(velocity.x, velocity.z)
		## Must be normalized for the dot_product to be between 0 and 1
		temp_velocity = temp_velocity.normalized()
		
		## Now we calculate the dot product between Player velocity and the wall's normal
		var dot_product: float = temp_velocity.dot(wall_normal_vector2)
		
		#print("DOT: ", dot_product)
		
		## If the dot_product is over the arbitrary value of dot_product_value (0.11 by default),
		## we consider the Player to be rubbing against the wall. We return true.
		## NOTE: The dot_product is negative when the Player is up against a wall, hence the "-"
		if dot_product <= -dot_product_value:
			return true
			
		
	
	## Otherwise (in both cases) we return false.
	return false

#endregion

#region Stairs-Handling functions
## NOTE: (the last two are utility and can be moved elsewhere, but this is fine)

## Due to the changes made by the Stairs-handling system, this function should be used
## instead of just player.is_on_floor()
func is_player_on_floor() -> bool:
	return (is_on_floor() or _snapped_to_stairs_last_frame)

## Check if the Player should be snapped up the stairs this frame;
## Used when the Player goes up the stairs, obviously.
func _snap_up_to_stairs_check(delta) -> bool:
	## This function will only be run if the Player is on floor at the moment
	if (not is_on_floor() and not _snapped_to_stairs_last_frame): return false
	## If the Player is moving up on the Y axis (jumping)
	## or they're not pressing any directional buttons, then also don't perform this function
	if (self.velocity.y > 0 or direction.length() == 0): return false
	
	## The position at which we expect the Player to be next frame;
	## Only X and Y axes matter
	var expected_move_motion: Vector3 = self.velocity * Vector3(1, 0, 1) * delta
	
	## BodyTestMotion's starting position;
	## a bit in the direction the Player is moving and two steps higher then the Player
	## (higher - to see if something is blocking the Player)
	var step_pos_with_clearance: Transform3D = \
		self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	
	## We use TestMotion to move the 'dummy' Player down to check where to snap them
	var down_check_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
	
	## Run the check down from the granted position;
	## if it returns something and the collision's result is a surface...
	if (_run_body_test_motion(step_pos_with_clearance, \
		Vector3(0, -MAX_STEP_HEIGHT * 2, 0), down_check_result) \
		and \
		(down_check_result.get_collider().is_class("StaticBody3D") or \
		down_check_result.get_collider().is_class("CSGShape3D"))):
			## Check how far up we must move the Player to correctly snap them to the step
			var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - \
			self.global_position).y
			
			## If it's too high for the Player to step up, or the step is too small to matter,
			## then we return false and don't do snap the Player;
			## NOTE: (step_height <= 0.01) seems to prevent glitches, apparently.
			## NOTE: The third 'or' is to check if the Player's 'feet' are at the correct position;
			## I.e. the Player's origin point MUST ALWAYS be located at the bottom of the Collider
			#if ((step_height > MAX_STEP_HEIGHT) or (step_height <= 0.01) or \
			#((down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT)):
				#return false 
			
			if ((step_height > MAX_STEP_HEIGHT) or (step_height <= 0.001) or \
			((down_check_result.get_collision_point() - %Feet.global_position).y > MAX_STEP_HEIGHT)):
				print("ERROR LIES HERE! 0")
				return false 
			
			#
			#if ((step_height > MAX_STEP_HEIGHT) or (step_height <= 0.01)):
				#print("ERROR LIES HERE! 1")
				#return false
			#if ((down_check_result.get_collision_point() - %Feet.global_position).y > MAX_STEP_HEIGHT):
				#print("ERROR LIES HERE! 2")
				#return false 
			
			
			
			## Everyting seems fine, we can now snap the Player to the step.
			
			## Place the StairsAheadRaycast3D to the check's collision point
			## and up by MAX_STEP_HEIGHT,
			## and a bit in the direction of the Player's expected movement ;
			## This should hit the flat part of the stairs
			%StairsAheadRayCast.global_position = down_check_result.get_collision_point() + \
				Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
			## Now we check if this RayCast finds a valid step, and if it does, apply snapping
			%StairsAheadRayCast.force_raycast_update()
			if (%StairsAheadRayCast.is_colliding() \
			and not is_surface_too_steep(%StairsAheadRayCast.get_collision_normal())):
				## And move the Player a bit above the surface
				self.global_position = step_pos_with_clearance.origin + \
				down_check_result.get_travel();
				
				## Snap the Playey down to the surface. Done!
				apply_floor_snap() ## Update to make absolutely sure the Player is on floor
				_snapped_to_stairs_last_frame = true
				
				#print("WORKING!")
				return true
			
		
	
	## If the snap didn't happen, return false (by default)
	return false

## Check if the Player should be snapped down the stairs this frame;
## That's when they're currently flying off the stairs, typically
func _snap_down_to_stairs_check() -> void:
	## Did the Player snap down the stair due to this check?
	## Used to update _snapped_to_stairs_last_frame
	var did_snap: bool = false
	
	## If the surface-detecting RayCast below the Player detects a surface,
	## and that surface isn't too steep, then we can snap the Player down.
	var floor_below: bool = %StairsBelowRayCast.is_colliding() \
		and not is_surface_too_steep(%StairsBelowRayCast.get_collision_normal())
	
	## Was the Player on the floor last frame?
	## If the current frame is right after Player flew off the stairs, we will try to snap them down
	var was_on_floor_last_frame: bool = \
		(Engine.get_physics_frames() - _last_frame_was_on_floor == 1)
	
	## We will only snap down the stairs in these conditions...
	## not on floor, falling down, valid surface below the Player, and
	## Player is indeed going down the stairs (as known from last frame)...
	if (not is_on_floor() and velocity.y <= 0 and floor_below and\
			(was_on_floor_last_frame or _snapped_to_stairs_last_frame)):
		## The conditions check out;
		## Make the check down to see if there's a surface there, and if there is, apply snapping
		var body_test_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			## Surface found - there's a step below the Player;
			## this is the exact position a little above the step
			var translate_y: float = body_test_result.get_travel().y
			## Snap the Player down
			self.position.y += translate_y
			apply_floor_snap() ## Update to make absolutely sure the Player is on floor
			did_snap = true
			
		
	
	_snapped_to_stairs_last_frame = did_snap;

## When snapping the Player down to the floor, we must know if the surface
## we're snapping down to isn't too steep.
## Passed 'normal' Vector3 is the normal of the surface we're snapping to.
func is_surface_too_steep(normal: Vector3) -> bool:
	return (normal.angle_to(Vector3.UP) > self.floor_max_angle)

## we'll use PhysicsServer3D's TestMotion for this
## 'from' variable is the original position of the Player when TestMotion is tested
## 'motion' in this case is directly down;
## but typically, the direction in which the check will be performed from 'from' position
## 'result' variable holds the results of this check
func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	## Null result, we make a new one
	if not result: result = PhysicsTestMotionParameters3D.new()
	
	## Defining parameters for PhysicsServer3D to use
	var params: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	
	## Perform the check, we'll use 'results' to get the position where the Player will be snapped
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

#endregion

#region ## Player Camera functions, Camera Smoothing

## Makes the PlayerCamera (of ShakeableCamera class) shake with given trauma_value
func shake_camera(trauma_value) -> void:
	%PlayerCamera.add_trauma(trauma_value)
	

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

#region 

###-------------------------------------------------------------------------###
##### Health and Death
###-------------------------------------------------------------------------###

func take_damage(amount: float) -> void:
	health -= amount
	
	UImanager.update_health_UI()


#endregion
