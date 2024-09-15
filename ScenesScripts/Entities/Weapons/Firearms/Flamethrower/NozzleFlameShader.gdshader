shader_type spatial;
// Unshaded because we don't want this Mesh to receive any Shadows - it's a Flame afterall.
render_mode unshaded;


// This code is from Heartbeast's "Flat Fire Shader Tutorial - Godot 4"
// tutorial - (https://www.youtube.com/watch?v=sCIr_58NN48)
// Commented and edited by MindVisceral.


// How far up/down the Flame should be moved;
// higher number - more flames, lower number - more transparency. Value of 0.5 is ideal.
uniform float y_offset = 0.25;
// How fast the Flames scroll 'UP'
uniform float flame_speed = 0.54;

// Color of the Flames themselves
uniform vec4 flame_color: source_color = vec4(1.0);
// Exported Noise texture.
uniform sampler2D noise_texture: hint_default_black, repeat_enable;


void fragment() {
	
	// The UV texture should move with time. We use flame_speed float for control.
	float time_multiplier = TIME * flame_speed;
	// Apply scrolling to the 'uv'.
	// X is added to and Y is subtracted from, because that's what works with this custom cone Mesh
	vec2 uv = vec2(UV.x + time_multiplier, UV.y - time_multiplier);
	// Apply noise to the texture for nice flames.
	vec4 noise = texture(noise_texture, uv);
	vec4 final_color = noise;
	// Offset was explained above already. Apply it (with subtraction, because that's what works.)
	final_color.rgb += vec3(UV.y - y_offset);
	// Apply step for clear distinction between black and white in our noise.
	final_color.rgb = step(final_color.rgb, vec3(0.5));
	
	// Set the final_color's Alpha value to its Red value. This is how we get out transparency.
	final_color.a = final_color.r;
	
	// Set the actual color part of the color.
	final_color.rgb = flame_color.rgb;
	
	// Apply final_color to ALBEDO.
	// We can't use final_color's Alpha value here, because ALBEDO is a vec3, hence 'rgb'
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}
