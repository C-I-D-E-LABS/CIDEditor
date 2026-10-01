#define SKY_PANORAMA_FRAG
#include "foxlite/inc/foxlite.glsl"
#include "foxlite/inc/material.glsl"
#include "foxlite/inc/sky.glsl"      // For worldDirection and sky funcs

void main() {
	gl_FragColor = panoramaSky(skyTexture, normalize(worldDirection));
}