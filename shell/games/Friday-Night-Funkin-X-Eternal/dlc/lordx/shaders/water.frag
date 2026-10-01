#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;
uniform float intensityMod = 1.0; //Modify me to make shader less or more intense :3
uniform float intensityModX = 1.0; //Specific X intensity
uniform float intensityModY = 1.0; //Specific Y ntensity
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

void mainImage()
{
    vec2 uv = fragCoord.xy / iResolution.xy;
//	uv.y = -uv.y;

uv.y += (cos((uv.y + (iTime * 0.06)) * (45.0 * (intensityModY * intensityMod))) * 0.0040) +
    (cos((uv.y + (iTime * 0.3)) * (10.0 * (intensityModY * intensityMod))) * 0.002);

uv.x += (sin((uv.y + (iTime * 0.09)) * (25.0 * (intensityModX * intensityMod))) * 0.00500) +
    (sin((uv.y + (iTime * 0.3)) * (15.0 * (intensityModX * intensityMod))) * 0.002);
    

    vec4 texColor = texture(iChannel0,uv);
    fragColor = texColor;
}