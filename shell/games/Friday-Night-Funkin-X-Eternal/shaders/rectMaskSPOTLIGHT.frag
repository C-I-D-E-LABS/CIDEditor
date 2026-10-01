#pragma header
uniform vec2 u_mouse;   // mouse in local sprite coords (pixels)
uniform float u_radius; // radius in pixels
uniform float u_darkness;

void main() {
    vec2 uv = openfl_TextureCoordv.xy * openfl_TextureSize.xy;
    vec4 color = texture2D(bitmap, openfl_TextureCoordv.xy);

    float dist = distance(uv, u_mouse);

    // aliased circle edge
    float mask = 1.0 - smoothstep(u_radius - fwidth(dist), u_radius + fwidth(dist), dist);

    // inside circle = normal, outside = dark
    vec3 spotlight = mix(color.rgb * u_darkness, color.rgb, mask); // 0.2 = darkness outside

    gl_FragColor = vec4(spotlight, color.a);
}
