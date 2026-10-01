#pragma header

uniform float value; // from -0.5 to -1.0 its fade to black, from 0.5 to 1.0 its fade to white

void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

	float t = pow(abs(value), 14.0) * sign(value);
	vec3 target = t >= 0.0 ? vec3(1.0) : vec3(0.0);
	color.rgb = mix(color.rgb, target, abs(t));

	gl_FragColor = color;
}