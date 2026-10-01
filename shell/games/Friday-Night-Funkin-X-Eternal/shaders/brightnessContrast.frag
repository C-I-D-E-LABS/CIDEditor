#pragma header

// Control Uniforms
uniform float uBwIntensity; // 0.0 = full color, 1.0 = pure black & white look
uniform float uBrightness;  // Default: 0.0 (Range: -1.0 to 1.0)
uniform float uContrast;    // Default: 1.0 (Range:  0.0 to 2.0)

void main() {
    // 1. Sample the original texture color
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    vec3 originalColor = color.rgb;

    // 2. Create the black and white base
    float gray = dot(originalColor, vec3(0.299, 0.587, 0.114));
    vec3 bwColor = vec3(gray);

    // 3. Apply contrast and brightness to the black and white base
    bwColor = ((bwColor - 0.5) * max(uContrast, 0.0)) + 0.5;
    bwColor += uBrightness;

    // 4. Smoothly blend between original color and the edited B&W look
    vec3 finalColor = mix(originalColor, bwColor, clamp(uBwIntensity, 0.0, 1.0));

    // 5. Output with the original transparency preserved
    gl_FragColor = vec4(finalColor, color.a);
}
