#pragma header

uniform float threshold; // e.g. 0.25
uniform float softness;  // e.g. 0.05

vec3 rgb2hsv(vec3 c) {
    float Cmax = max(max(c.r, c.g), c.b);
    float Cmin = min(min(c.r, c.g), c.b);
    float delta = Cmax - Cmin;

    float h = 0.0;
    float s = (Cmax > 0.0) ? delta / Cmax : 0.0;

    if (delta > 0.0) {
        if (Cmax == c.r) h = (c.g - c.b) / delta;
        else if (Cmax == c.g) h = 2.0 + (c.b - c.r) / delta;
        else h = 4.0 + (c.r - c.g) / delta;
        h = fract(h / 6.0);
    }

    return vec3(h, s, Cmax);
}

float greenMask(vec3 c) {
    vec3 green = vec3(0.0, 1.0, 0.0);
    vec3 weights = vec3(6.0, 216.0/225.0, 1.0);

    vec3 hsv = rgb2hsv(c);
    vec3 hsvGreen = rgb2hsv(green);
    float dist = length(weights * (hsvGreen - hsv));
    return smoothstep(threshold, threshold + softness, dist);
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec4 tex = flixel_texture2D(bitmap, uv);
    float mask = greenMask(tex.rgb); // 0 = green, 1 = keep
    gl_FragColor = vec4(tex.rgb * mask, tex.a * mask);
}
