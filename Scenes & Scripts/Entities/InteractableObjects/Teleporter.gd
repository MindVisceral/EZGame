class_name Teleporter
extends StaticBody3D

@export var teleport_target: Node3D
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
			
			## Play Teleporter effects
			audio_player.play()
			
			## Start the cooldown
			## NOTE: Unneccesary - only useful if the teleport_target is a Teleporter too
			teleport_cooldown.start()
			
			## If a target is set, teleport the thing to that target's position.
			if teleport_target:
				if teleport_target is Teleporter:
					teleport_target.teleport_cooldown.start()
					teleport_target.audio_player.play()
				
				thing.global_position = teleport_target.position
