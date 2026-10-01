// https://www.shadertoy.com/view/Xltfzj

#pragma header
vec2 uv = openfl_TextureCoordv.xy;
uniform float iTime;
    
uniform float directions; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
uniform float quality; // BLUR QUALITY (Default 4.0 - More is better but slower)
uniform float size; // BLUR SIZE (Radius)
    
void main()
{
    float Pi = 6.28318530718; // Pi*2
           
    vec2 Radius = size/openfl_TextureSize.xy;
        
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (openfl_TextureCoordv*openfl_TextureSize) /openfl_TextureSize.xy;
    // Pixel colour
    vec4 Color = flixel_texture2D(bitmap, uv);
        
    // Blur calculations
    for( float d=0.0; d<Pi; d+=Pi/directions)
    {
        for(float i=1.0/quality; i<1.001; i+=1.0/quality)
        {
            Color += flixel_texture2D( bitmap, uv+vec2(cos(d),sin(d))*Radius*i);		
        }
    }
        
    // Output to screen
    Color /= quality * directions + 1.0;
    gl_FragColor = Color;
}