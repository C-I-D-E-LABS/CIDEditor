// https://www.shadertoy.com/view/4sVfzW

#pragma header

uniform float value; // from -0.5 to -1.0 its fade to black, from 0.5 to 1.0 its fade to white 

const vec3 offsets = normalize(vec3(5.0, 2.0, 1.0));
void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

	float t = pow(abs(value), 14.0) * sign(value);
	color.rgb = clamp(color.rgb + t * offsets * 8.0, 0.0, 1.0);
	gl_FragColor = color;
}