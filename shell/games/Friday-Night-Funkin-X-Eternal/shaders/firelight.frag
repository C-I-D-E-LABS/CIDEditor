#pragma header

uniform float iTime;
uniform float amount;

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    float a0 = color.a;
    
    float glow = 0.0;
    
    float maxRadius = 12.0 / 512.0;
    int samples = 16; // Ms samples = ms suave pero ms pesado
    
    for(int i = 0; i < samples; i++) {
        float angle = float(i) * 6.28318 / float(samples);
        
        for(int r = 1; r <= 4; r++) {
            float radius = maxRadius * float(r) / 4.0;
            vec2 offset = vec2(cos(angle), sin(angle)) * radius;
            
            float sampleAlpha = flixel_texture2D(bitmap, openfl_TextureCoordv + offset).a;
            float edge = abs(a0 - sampleAlpha);
            
            float weight = 1.0 - (float(r) / 4.0);
            glow += edge * weight;
        }
    }
    
    glow = glow / float(samples * 4);
    glow = smoothstep(0.0, 0.3, glow) * color.a;

    float flicker = sin(iTime * 3.0) * 0.15 + 0.85;
    float pulse = sin(iTime * 1.5) * 0.1 + 0.9;
    float fireAnim = flicker * pulse;

    vec3 glowColor = vec3(1.0, 0.65, 0.3);
    float strength = clamp(amount, 0.0, 1.0);
    color.rgb = color.rgb + glowColor * glow * 0.7 * fireAnim * strength;

    float fireTint = 0.5 * fireAnim * strength;
    color.r = color.r + fireTint * 0.5;
    color.g = color.g + fireTint * 0.25;
    color.b = color.b - fireTint * 0.15;
    color *= color.a;

    color.rgb = clamp(color.rgb, 0.0, 1.0);

    gl_FragColor = color;
}
