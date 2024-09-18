shader_type spatial;
// Unshaded because we don't want this Mesh to receive any Shadows - it's a Flame afterall.
render_mode unshaded;
// And backface culling is disabled - this way we can also see the other side of the Flame cone
render_mode cull_disabled;


// This code is from Heartbeast's "Flat Fire Shader Tutorial - Godot 4"
// tutorial - (https://www.youtube.com/watch?v=sCIr_58NN48)
// Commented and edited by MindVisceral.


// How far up/down the Mesh the Flame should be moved (think: relatively to the middle of the Mesh);
// higher number - more flames, lower number - more transparency. Value of 0.45 is ideal.
uniform float y_offset: hint_range(0.0, 1.0, 0.01) = 0.45;
// How fast the Flames scroll 'UP'
uniform float flame_speed = 0.54;

// Color of the Flames themselves
uniform vec4 flame_color: source_color = vec4(1.0);
// Exported Noise texture.
uniform sampler2D noise_texture: hint_default_black, repeat_enable;


void fragment() {

	// Apply scrolling over TIME to the 'uv'.
	vec2 uv = vec2(UV.x, UV.y + TIME * flame_speed);
	// Apply noise to the texture for nice flames.
	vec4 noise = texture(noise_texture, uv);
	vec4 final_color = noise;
	// Offset was explained above already. Apply it.
	final_color.rgb += vec3(UV.y - y_offset);
	// Apply step for clear distinction between black and white in our noise.
	final_color.rgb = step(final_color.rgb, vec3(0.5));
	// Flip black and white values so the noise animates the right way.
	final_color.rgb = vec3(1.0) - final_color.rgb;

	// Set the final_color's Alpha value to its Red value. This is how we get out transparency.
	final_color.a = final_color.r;

	// Set the actual color part of the color.
	final_color.rgb = flame_color.rgb;

	// Apply final_color to ALBEDO.
	// We can't use final_color's Alpha value here, because ALBEDO is a vec3 (hence 'rgb')
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}
