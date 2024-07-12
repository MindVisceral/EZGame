## @tool because we use configuration warnings for this node
@tool

class_name Teleporter
extends StaticBody3D

@export var teleport_target: Node3D:
	get:
		return teleport_target
	set(value):
		teleport_target = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
@export var effects_colour: Color = Color("b291ff")

@onready var particles: GPUParticles3D = $Particles
@onready var light: OmniLight3D = $Particles/Light
@onready var animPlayer: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer
@onready var teleport_cooldown: Timer = $TeleportCooldown


func _ready() -> void:
	## Change the Teleporter's effects' colors
	particles.process_material.color = effects_colour
	light.light_color = effects_colour

## When something enters a teleporter...
func _teleport_area_entered(thing: Node3D) -> void:
	if thing:
		if teleport_cooldown.is_stopped():
			## If a target is set, teleport the thing to that target's position and play effects
			if teleport_target:
				## Play Teleporter effects
				audio_player.play()
				## Start the cooldown
				## NOTE: Sometimes unneccesary - only useful if the teleport_target is a Teleporter
				teleport_cooldown.start()
				
				if teleport_target is Teleporter:
					teleport_target.teleport_cooldown.start()
					teleport_target.audio_player.play()
				
				thing.global_position = teleport_target.global_position



func _get_configuration_warnings() -> PackedStringArray:
	if teleport_target == null:
		return ["Teleport target not set!"]
	return []
