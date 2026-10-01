#pragma header

#ifdef GL_ES
precision lowp float;
#endif

uniform float iTime;
uniform vec4 color;
uniform vec2 size;
uniform float frameRate;
uniform bool mixColors;

#define PHI 1.61803398874989484820459

float gold_noise(in vec2 xy, in float seed) {
	return fract(tan(distance(xy * PHI, xy) * seed) * xy.x);
}

float staticSized(vec2 fragCoord, float seed, vec2 size) {
	fragCoord = floor(fragCoord / size) + 1.0;
	return gold_noise(fragCoord, seed);
}

void main() {
	gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

	vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
	float seed = floor(iTime * frameRate) / frameRate;

	if (mixColors) {
		gl_FragColor.rgb = mix(gl_FragColor.rgb, color.rgb, floor(staticSized(fragCoord, seed, size) + 0.5) * gl_FragColor.a * color.a);
	} else {
		gl_FragColor.r = mix(gl_FragColor.r, color.r, floor(staticSized(fragCoord, seed, size) + 0.5) * gl_FragColor.a * color.a);
		gl_FragColor.g = mix(gl_FragColor.g, color.g, floor(staticSized(fragCoord, seed + 0.1, size) + 0.5) * gl_FragColor.a * color.a);
		gl_FragColor.b = mix(gl_FragColor.b, color.b, floor(staticSized(fragCoord, seed + 0.2, size) + 0.5) * gl_FragColor.a * color.a);
	}
}
