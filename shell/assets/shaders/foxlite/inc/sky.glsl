#ifndef SKY_RADIANCE_LEVEL
#define SKY_RADIANCE_LEVEL 8
#endif

uniform vec2 skyOffset;
uniform sampler2D skyTexture;

varying vec3 worldDirection;
varying mat3 worldBasis;

vec2 coordFromSphere(vec3 dir) {
    return vec2(
        0.5 - atan(dir.x, dir.z) / TAU,
        0.5 - asin(dir.y) / PI
    );
}

#ifdef FRAGMENT
// LOD version for fragment shader only
// Stops WebGL from crashing
vec4 panoramaSky(sampler2D skyTex, vec3 direction, float lod) {
	return texture2D(skyTex, coordFromSphere(direction) + skyOffset, lod);
}

vec4 panoramaSky(sampler2D skyTex, vec3 direction) {
	return texture2D(skyTex, coordFromSphere(direction) + skyOffset);
}
#endif