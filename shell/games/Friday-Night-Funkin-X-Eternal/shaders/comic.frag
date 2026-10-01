#pragma header

mat2 rotate2d(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

float dotScreen(vec2 uv, float angle, float scale) {
    vec2 p = (uv - vec2(0.5)) * openfl_TextureSize.xy;
    vec2 q = rotate2d(angle) * p * scale;
    return (sin(q.x) * sin(q.y)) * 0.5 + 0.5; // Normalize to 0.0 - 1.0
}

void main() {
    vec2 uv = openfl_TextureCoordv.xy;
    vec3 col = texture2D(bitmap, uv).rgb;

    float angle = 0.4;
    float scale = 1.3;
    float pattern = dotScreen(uv, angle, scale);

    // Apply the pattern as a brightness multiplier (normalized)
    col *= mix(0.7, 1.3, pattern);

    gl_FragColor = vec4(col, 1.0);
}
