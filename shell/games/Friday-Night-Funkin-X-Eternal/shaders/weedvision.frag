#pragma header

uniform float daHue;

void main()
{
	vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
	float hue = mod(daHue, 3.0);

	vec3 hueTerm = 1.0 - min(abs(vec3(hue) - vec3(0.0, 2.0, 1.0)), 1.0);
	hueTerm.x = 1.0 - dot(hueTerm.yz, vec2(1.0));

	vec3 color = vec3(
		dot(tex.rgb, hueTerm.xyz),
		dot(tex.rgb, hueTerm.zxy),
		dot(tex.rgb, hueTerm.yzx)
	);

	gl_FragColor = vec4(color * tex.a, tex.a);
}
