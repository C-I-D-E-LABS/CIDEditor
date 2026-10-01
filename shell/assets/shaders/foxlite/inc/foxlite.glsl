#extension GL_EXT_shader_framebuffer_fetch : enable
#extension GL_EXT_gpu_shader4 : enable

// For MRTs... IF I HAD ONE
#ifdef GL_ES
#extension GL_EXT_draw_buffers : enable
#else
#extension GL_ARB_draw_buffers : enable
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
precision highp int;
#else
precision mediump float;
precision mediump int;
#endif
#endif

#pragma foxflags
#pragma shadow_program_check
#pragma optimize(on)

// Constants
#define PI  3.14159265358979
#define TAU 6.28318530717959

#include "foxlite/inc/polyfills.glsl"

// ---------- Legacy support for OpenGL 3 ----------

#if __VERSION__ >= 300
#define texture2D texture
#define texture2DLod textureLod
#define textureCube texture

#ifdef VERTEX
#define attribute in
#define varying out
#endif

#ifdef FRAGMENT
#define varying in
#ifdef FORWARDPLUS
layout(location = 0) out vec4 _GL_DRAW_BUFFERS[4];
#else
layout(location = 0) out vec4 _GL_DRAW_BUFFERS[1];
#endif
#define gl_FragData _GL_DRAW_BUFFERS
#define gl_FragColor gl_FragData[0]
#endif
#endif

// -------------------------------------------------

// User uniforms
uniform vec2 iResolution;		// Camera Viewport size

#ifdef FRAGMENT
#define ScreenCoord gl_FragCoord.xy
#define ScreenUV (gl_FragCoord.xy/iResolution.xy)
#endif

#ifdef VERTEX
#define ScreenUV (gl_Position.xy*0.5+0.5)
#define ScreenCoord (ScreenUV * iResolution.xy)
#endif 

// Transforms
// Precomputed transforms are disabled for now, HScript performance gains, a bit more GPU processing, but that's fine probably
//uniform mat4 modelView; 	 	// Model transform with Camera transform 
//uniform mat4 invModelView;    // Inverse model view 
uniform mat4 model;				// Model transform alone
uniform mat4 view;				// Camera transform
uniform mat4 invView;			// inverse camera transform (position, rotation)
								// For light calculations

uniform mat4 projection; 		// Camera projection (fov, aspectRatio, clipping)
uniform mat4 invProjection;     // Inverse camera projection for screen-space raytracing effects

#ifdef PSX_AFFINE_MAPPING
noperspective varying vec2 foxlite_TexCoordv; // Texture coordinates (no perspective correction)
#else
varying vec2 foxlite_TexCoordv; // Texture coordinates
#endif
varying vec4 foxlite_Colorv;	// Vertex colors
varying vec4 viewPosition;    	// View-space
varying vec3 modelViewNormal; 	// Computed normal-view transformation for deferred renderers
varying mat3 TBN; 				// Tangent, Binormal and Normal matrix for advanced lighting calculations with normal maps
								// (Used for PBR rendering)

// Space coordinates

vec3 screenToNDC(vec2 uv) {
	return vec3(uv * 2.0 - 1.0, 0.0);
}

// Z-buffer version
vec3 screenToNDC(vec3 p) {
	return p * 2.0 - 1.0;
}

vec4 ndcToView(vec3 ndc) {
	vec4 view = invProjection * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return view;
}

vec3 viewToWorld(vec4 view) {
	vec3 world = transpose(basis(invView)) * view.xyz;
	return world;
}

vec3 viewToWorld(vec3 view) {
	vec3 world = transpose(basis(invView)) * view.xyz;
	return world;
}

vec4 worldToView(vec3 world) {
	return view * vec4(world, 1);
}

vec2 nearFarFromProjection(mat4 proj) {
	float m22 = proj[2][2]; // idx 10
	float m32 = proj[3][2]; // idx 14
	float nearP = m32 / (m22 - 1.0);
	float farP  = m32 / (m22 + 1.0);
	return vec2(nearP, farP);
}

mat3 basisFromDirection(vec3 dir) {
	vec3 forward = normalize(dir);
	float ref = step(0.999, abs(forward.y));
	vec3 right = normalize(cross(vec3(0, 1.0-ref, ref), forward));
	vec3 up = cross(forward, right);
	return mat3(right, up, forward);
}

float linearizeDepth(float depth, float near) {
	return near / (1.0 - depth * (1.0 - near));
}

float linearizeDepthExact(float depth, float near, float far) {
    float z = depth * 2.0 - 1.0; // Back to NDC 
    return (2.0 * near * far) / (far + near - z * (far - near));
}

// I don't remember from which shader is this, I'm sorry!!
// Creates a TBN matrix from a normal and a tangent
mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
    // For DirectX normal mapping you want to switch the order of these
    vec3 bitangent = cross(normal, tangent);
    return mat3(tangent, bitangent, normal);
}

float interleavedGradientNoise(vec2 n) {
    float f = 0.06711056 * n.x + 0.00583715 * n.y;
    return fract(52.9829189 * fract(f));
}

// Bayer dithering without bitwise ops from: https://www.shadertoy.com/view/4ssfWM
float Bayer2(vec2 a) {
    a = floor(a);
    return fract(a.x / 2.0 + a.y * a.y * 0.75);
}

// Function instead of define for Mobile GLSL
float Bayer4(vec2 a) {
	return Bayer2(0.5*a)*0.25 + Bayer2(a);
}

#define Bayer8(a) (Bayer4 (0.5 *(a)) * 0.25 + Bayer2(a))

#ifdef FRAGMENT
float alphaDither(float alpha) {
	#ifdef ALPHA_DITHER_FAST
	// Discard 2x2 fragments rather than 1x1 (saves performance)
	return floor(min(alpha*1.0061 + Bayer8(gl_FragCoord.xy*0.5), 1.0));
	#else
	return floor(min(alpha*1.0061 + Bayer8(gl_FragCoord.xy), 1.0));
	#endif
}
#endif

vec2 fox_textureBufferVec2(sampler2D data, int i, float pixelSize) {
	#if __VERSION__ < 300
	int idx = int(mod(float(i), 2.0));
	#else
	int idx = i % 2;
	#endif
	i /= 2;

	#if __VERSION__ >= 300
	vec4 s = texelFetch(data, ivec2(i, 0), 0);
	#elif defined(VERTEX)
	vec4 s = texture2DLod(data, vec2(float(i) * pixelSize, 0), 0.0);
	#else
	vec4 s = texture2D(data, vec2(float(i) * pixelSize, 0));
	#endif
	return mix(s.xy, s.zw, float(idx));
}

vec4 fox_textureBufferVec4(sampler2D data, int i, float pixelSize) {
	#if __VERSION__ >= 300
		return texelFetch(data, ivec2(i, 0), 0);
	#elif defined(VERTEX)
		return texture2DLod(data, vec2(float(i) * pixelSize, 0), 0.0);
	#else
		return texture2D(data, vec2(float(i) * pixelSize, 0));
	#endif
}

mat4 fox_textureBufferMat4(sampler2D data, int i, float pixelSize) {
	i *= 4;
	#if __VERSION__ >= 300
	vec4 c0 = texelFetch(data, ivec2(i  , 0), 0);
	vec4 c1 = texelFetch(data, ivec2(i+1, 0), 0);
	vec4 c2 = texelFetch(data, ivec2(i+2, 0), 0);
	vec4 c3 = texelFetch(data, ivec2(i+3, 0), 0);
	#elif defined(VERTEX)
	float j = float(i); // Sample pixel center
	vec4 c0 = texture2DLod(data, vec2((j+0.5) * pixelSize, 0), 0.5);
	vec4 c1 = texture2DLod(data, vec2((j+1.5) * pixelSize, 0), 0.5);
	vec4 c2 = texture2DLod(data, vec2((j+2.5) * pixelSize, 0), 0.5);
	vec4 c3 = texture2DLod(data, vec2((j+3.5) * pixelSize, 0), 0.5);
	#else
	float j = float(i); // Sample pixel center
	vec4 c0 = texture2D(data, vec2((j+0.5) * pixelSize, 0.5));
	vec4 c1 = texture2D(data, vec2((j+1.5) * pixelSize, 0.5));
	vec4 c2 = texture2D(data, vec2((j+2.5) * pixelSize, 0.5));
	vec4 c3 = texture2D(data, vec2((j+3.5) * pixelSize, 0.5));
	#endif
	return mat4(c0, c1, c2, c3);
}