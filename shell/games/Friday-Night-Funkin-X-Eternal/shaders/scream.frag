#pragma header

uniform float iTime;
uniform float power;

float noise(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void main() {
	vec2 uv = openfl_TextureCoordv;
	vec2 px = 1.0 / openfl_TextureSize;
	float strength = clamp(power, 0.0, 1.0);

	if (strength <= 0.001) {
		gl_FragColor = flixel_texture2D(bitmap, uv);
		return;
	}

	float tick = floor(iTime * 30.0);
	float band = floor(uv.y * 86.0);
	float chunk = floor(uv.y * 14.0);
	float tear = step(0.69, noise(vec2(band, tick))) * strength;
	float block = step(0.74, noise(vec2(chunk, tick * 0.5))) * strength;
	float wave = sin(uv.y * 150.0 + iTime * 66.0) * px.x * 11.0 * strength;
	float shove = (noise(vec2(tick, band + 9.0)) - 0.5) * 0.13 * tear;
	float chunkShove = (noise(vec2(chunk + 3.0, tick)) - 0.5) * 0.09 * block;

	vec2 p = uv;
	p.x = clamp(p.x + wave + shove + chunkShove, 0.0, 1.0);
	p.y = clamp(p.y + ((noise(vec2(band + 4.0, tick)) - 0.5) * px.y * 34.0 * (tear + block)), 0.0, 1.0);

	float split = (4.0 + 20.0 * strength + 24.0 * tear + 18.0 * block) * px.x;
	vec4 base = flixel_texture2D(bitmap, p);
	vec3 col;
	col.r = flixel_texture2D(bitmap, p + vec2(split, 0.0)).r;
	col.g = base.g;
	col.b = flixel_texture2D(bitmap, p - vec2(split, 0.0)).b;

	float grain = noise(uv * openfl_TextureSize + iTime * 240.0) - 0.5;
	float scan = sin(uv.y * openfl_TextureSize.y * 2.2);
	float cut = step(0.965, noise(vec2(band * 3.0, tick + 12.0))) * strength;

	col.r += 0.18 * strength + cut * 0.25;
	col.g *= 1.0 - 0.12 * strength;
	col.b *= 1.0 - 0.16 * strength;
	col += grain * 0.18 * strength;
	col *= 1.0 - ((scan * 0.5 + 0.5) * 0.16 * strength);
	col = mix(col, vec3(col.r * 1.18, col.g * 0.72, col.b * 0.72), 0.22 * strength);

	gl_FragColor = vec4(clamp(col, 0.0, 1.0), base.a);
}
