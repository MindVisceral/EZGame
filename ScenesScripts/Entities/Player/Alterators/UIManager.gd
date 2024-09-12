class_name UIManager
extends Node


###-------------------------------------------------------------------------###
##### Exported variables and References
###-------------------------------------------------------------------------###

## Reference to the Player, so its functions and variables can be accessed directly
var player: Player


@export_group("References")

## Reference to the "UI" Control Node. All UI elements are children of this Control Node.
@export var UI_reference: Control

## Reference to the StatusEffectOverlay Control Node.
## It display's the Player's Status Effect on the whole screen.
@export var StatusEffect_overlay: TextureRect


###-------------------------------------------------------------------------###
##### Setup
###-------------------------------------------------------------------------###

## This function handles stuff that can be done before init() is called as to not clutter init()
func _ready() -> void:
	## Disable StatusEffectOverlay, just to be safe.
	StatusEffect_overlay.visible = false
	

## This Node needs a reference to the Player to access its functions and variables
func init(player: Player) -> void:
	self.player = player
	
	## Every time a Status Effect is gained or lost, make sure the Status Effect Overalay
	## UI element is updated.
	player.StatusEffects.player_status_effects_changed.connect(toggle_status_effect_overlay)
	
	##
	update_health_UI()


###-------------------------------------------------------------------------###
##### Functions
###-------------------------------------------------------------------------###

## Enable or disable the Status Effect Overlay, depening on if the right Status Effect is on;
## some Status Effects make use of it to show that they're active
func toggle_status_effect_overlay() -> void:
	StatusEffect_overlay.visible = player.StatusEffects.check_for_status_effects()
	


## HERE: TEMPORARY - UI is not finalized
func update_health_UI() -> void:
	$"../../PlayerUI/UI/temp_healthUI".text = str(player.health)
