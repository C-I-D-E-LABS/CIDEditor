#pragma header

// --- Uniforms controlled from HScript ---
uniform float iTime;          // elapsed time (seconds)
uniform float intensity;      // overall strength  (default 1.0)
uniform float glitchHeight;   // 0-1 fraction of screen that glitches (default 0.35)

// ------------------------------------------------------------------
// Deterministic pseudo-random: takes a float seed, returns 0.0-1.0
// ------------------------------------------------------------------
float rand(float seed) {
    return fract(sin(seed * 127.1 + 311.7) * 43758.5453);
}

void main() {
    vec2 uv = openfl_TextureCoordv;

    // uv.y = 0.0 is TOP in OpenFL (flipped from OpenGL convention)
    // We want the glitch strongest at the top, so:
    float distFromTop = uv.y;                     // 0 = top edge, 1 = bottom
    float falloff     = 1.0 - smoothstep(0.0, glitchHeight, distFromTop);
    // falloff = 1 at very top, 0 below glitchHeight

    // --- Quantise time into "frames" so glitches stutter/freeze ---
    float frameDuration = 0.04;                   // ~25 fps stutter
    float t             = floor(iTime / frameDuration) * frameDuration;

    // --- Row-level displacement ---
    // Break the screen into coarse horizontal bands (~8px tall)
    float bandSize   = 0.012;
    float band       = floor(uv.y / bandSize);

    // Some bands get a big kick, most stay near zero
    float bigKick    = step(0.85, rand(band + t * 7.3));   // 15 % chance
    float shift      = (rand(band * 3.1 + t * 13.7) - 0.5) * 0.08 * bigKick;
    shift           += (rand(band * 7.9 + t * 5.1)  - 0.5) * 0.012; // tiny baseline jitter

    shift *= falloff * intensity;

    // --- Chromatic aberration (RGB split along X) ---
    float aberration = 0.006 * falloff * intensity;

    vec2 uvR = vec2(uv.x + shift + aberration, uv.y);
    vec2 uvG = vec2(uv.x + shift,              uv.y);
    vec2 uvB = vec2(uv.x + shift - aberration, uv.y);

    // Clamp to [0,1] so we don't sample outside the texture
    uvR = clamp(uvR, 0.0, 1.0);
    uvG = clamp(uvG, 0.0, 1.0);
    uvB = clamp(uvB, 0.0, 1.0);

    float r = flixel_texture2D(bitmap, uvR).r;
    float g = flixel_texture2D(bitmap, uvG).g;
    float b = flixel_texture2D(bitmap, uvB).b;
    float a = flixel_texture2D(bitmap, uvG).a;

    // --- Scanline duplication (copy a row from slightly above) ---
    // Randomly replace some rows with the row 2-4 px above them
    float rowRepeat = step(0.92, rand(band + t * 3.7)) * falloff * intensity;
    float dupOffset = rand(band + t * 2.1) * 0.025 + 0.004;
    vec2  uvDup     = clamp(vec2(uv.x + shift, uv.y - dupOffset), 0.0, 1.0);
    vec4  dupCol    = flixel_texture2D(bitmap, uvDup);

    vec4 glitchCol = vec4(r, g, b, a);
    vec4 finalCol  = mix(glitchCol, dupCol, rowRepeat);

    gl_FragColor = finalCol;
}