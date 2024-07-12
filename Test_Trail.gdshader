shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	ALBEDO = vec3(36.0, 10.0, 0.0);
	ALPHA = 0.2;
}

void light() {
	// Called for every pixel for every light affecting the material.
}
