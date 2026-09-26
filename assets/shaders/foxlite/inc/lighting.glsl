#ifndef LIGHTING_GLSL
#define LIGHTING_GLSL
#include "foxlite/inc/material.glsl" // For material data
#include "foxlite/inc/sdf3d.glsl"

// Lighting defines
// Note: - Positions must be in View-Space (view * X)
//		 - Directions must be in Inverse View-Space (invView * X)
// Calculations are made in view-space for future deferred lighting implementation

#define LIGHT_DIRECTIONAL 0
#define LIGHT_POINT 1
#define LIGHT_SPOT 2
#define LIGHT_AREA 3

#ifndef MAX_DIRECTIONAL_LIGHTS
	#define MAX_DIRECTIONAL_LIGHTS 4
#endif
#ifndef MAX_POINT_LIGHTS
	#define MAX_POINT_LIGHTS 16
#endif
#ifndef MAX_SPOT_LIGHTS
	#define MAX_SPOT_LIGHTS 8
#endif
#ifndef MAX_AREA_LIGHTS
	#define MAX_AREA_LIGHTS 8
#endif
#define TOTAL_LIGHTS (MAX_DIRECTIONAL_LIGHTS + MAX_POINT_LIGHTS + MAX_SPOT_LIGHTS + MAX_AREA_LIGHTS)

struct DirLight {
	vec4 color;
	vec4 direction;
	vec4 shadowRegion;
	vec4 shadowData;
};

struct PointLight {
	vec4 color;
	vec4 position;
	vec4 shadowData;
};

struct SpotLight {
	vec4 color;
	vec4 position;
	vec4 direction;
	vec4 shadowRegion;
	vec4 shadowData;
};

struct AreaLight {
	vec4 color;
	vec4 position;
	vec4 direction;
	vec4 sdfData;
	vec4 shadowData;
};

#if MAX_DIRECTIONAL_LIGHTS > 0
	uniform DirLight directionalLights[MAX_DIRECTIONAL_LIGHTS]; //  4*4 = 16 vector units
#endif
#if MAX_POINT_LIGHTS > 0
	uniform PointLight pointLights[MAX_POINT_LIGHTS];			// 16*3 = 48 vector units
#endif
#if MAX_SPOT_LIGHTS > 0
	uniform SpotLight spotLights[MAX_SPOT_LIGHTS];				//  8*5 = 40 vector units
#endif
#if MAX_AREA_LIGHTS > 0
	uniform AreaLight areaLights[MAX_AREA_LIGHTS];				//  8*5 = 40 vector units
#endif
uniform ivec4 lightCount; 									//   +1 = 145 vec4s for lights
															// lightCount: x=directional, y=point, z=spot, w=area


#if !defined(NO_SHADOW_CODE) && !defined(UNSHADED)
#include "foxlite/inc/shadow.glsl"
#endif

uniform vec3 ambientLight;


// https://dev.to/alex_ricciardi/light-interaction-in-computer-graphics-reflection-and-the-blinn-phong-model-opengl-mc9
float blinnPhong(vec3 lightDirection, vec3 viewPos, vec3 normal, float shininess) {
	vec3 viewDirection = normalize(viewPos);
	// Compute specular component using the Blinn-Phong model
	vec3 halfwayDir = normalize(lightDirection + viewDirection); // H
	float specularFactor = pow(max(dot(normal, halfwayDir), 0.0), shininess);
	
	return specularFactor;
}

// Custom light functions, outputs Diffuse and Specular factors from view-space

vec2 directionalLight(vec3 lightDir, vec3 viewPos, vec3 normal, float shininess) {
	float diffuse = max(dot(lightDir, normal)+uScattering, 0.0);
	float specular = blinnPhong(lightDir, viewPos, normal, shininess);
	return vec2(diffuse, specular); 
}

vec2 pointLight(vec3 lightPos, float radius, float attenuation, vec3 viewPos, vec3 normal, float shininess) {
	vec3 lightDir = -normalize(lightPos.xyz - viewPos);
	float diffuse = max(dot(lightDir, normal)+uScattering, 0.0);
	float specular = blinnPhong(lightDir, viewPos, normal, shininess);
	
	float intensity = 1.0 - clamp(distance(lightPos.xyz, viewPos) / radius, 0.0, 1.0);
	diffuse *= pow(intensity, attenuation);
	return vec2(diffuse, specular * diffuse);
}

// https://ogldev.org/www/tutorial21/tutorial21.html
vec2 spotLight(vec3 lightPos, vec3 lightDirection, float range, float angle, float attenuation, vec3 viewPos, vec3 normal, float shininess) {
	vec3 lightDir = -normalize(lightPos - viewPos);
	float spotFactor = dot(lightDir, lightDirection);

	// TODO: Add blur factor: when the cone is closer to the source, blur it less
	spotFactor = step(angle, spotFactor) * clamp((1.0 - (1.0 - spotFactor) * 1.0/(1.0 - angle)) , 0.0, 1.0);
	// Reuse pointLight function since spot is just a constrained version of it
	vec2 omni = pointLight(lightPos, range, attenuation, viewPos, normal, shininess);
	// Spot blob at surface
	//omni = mix(omni, omni / dist, 0.25);
		
	return min(omni * spotFactor, 2.0);
}

vec2 areaLight(vec3 lightPos, vec3 lightDirection, vec4 sdfData, float range, float attenuation, vec3 viewPos, vec3 normal, float shininess) {
	// Rotation vectors
	mat3 boxBasis = basisFromDirection(lightDirection);

	vec3 boxPos = viewToWorld(lightPos - viewPos);
	boxPos = boxBasis * boxPos;

	float d = getSDF3D(int(sdfData.w), boxPos, sdfData.xyz); // sdBox3D(boxPos, sdfData.xyz);
	float dist = range / max(d, 1.0);
	dist = clamp(dist, 0.0, 1.0);

	vec3 lightDir = -normalize(lightPos.xyz - viewPos);

	float diffuse = max(dot(lightDir, normal)+uScattering, 0.0);
	float specular = blinnPhong(lightDir, viewPos, normal, shininess);
	
	diffuse *= pow(dist, attenuation);
	return vec2(diffuse, specular * diffuse);
}	

void addLight(inout vec3 diffuse, inout vec3 specular, vec3 color, vec2 light) {
	#ifdef TOONLIGHT_3
	light = floor(light*3.0)/3.0;
	#elif defined(TOONLIGHT_2)
	light = floor(light*2.0)/2.0;
	#endif
	#ifndef NO_DIFFUSE
	diffuse += light.s * color;
	#endif
	#ifndef NO_SPECULAR
	specular += light.t * color;
	#endif
}

vec3 light(vec3 unlit, vec3 normal, vec3 viewPosition, vec3 lightSpecular, float shininess) {
	vec3 diffuse = ambientLight;
	vec3 specular = vec3(0);

	// Dynamic iterator values are not supported in some WebGL implementations...
	// So we do this crappy break check

	#if MAX_DIRECTIONAL_LIGHTS > 0
	for(int i = 0; i < MAX_DIRECTIONAL_LIGHTS; ++i) {
		if(i >= lightCount[LIGHT_DIRECTIONAL]) break;
		DirLight L = directionalLights[i];
		vec2 levels = directionalLight(L.direction.xyz, viewPosition, normal, shininess);
		#ifdef SHADOW_GLSL
		float shadow = 1.0;
		if(L.shadowData[ESHADOW_CASTER] >= 0.0 && levels.s != 0.0) shadow = shadowDirectional(directionalShadowLightSpace[i], L.shadowRegion, L.shadowData[ESHADOW_BLUR]);
		#else
		const float shadow = 1.0;
		#endif
		addLight(diffuse, specular, L.color.rgb, shadow * levels);
	}
	#endif

	#if MAX_POINT_LIGHTS > 0
	for(int i = 0; i < MAX_POINT_LIGHTS; ++i) {
		if(i >= lightCount[LIGHT_POINT]) break;
		PointLight L = pointLights[i];
		#ifdef SHADOW_GLSL
		float shadow = 1.0;
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) shadow = shadowPointCubemap(pointShadowLightSpace[0]);
		#else
		const float shadow = 1.0;
		#endif
		addLight(diffuse, specular, L.color.rgb, shadow * pointLight(L.position.xyz, L.color.w, L.position.w, viewPosition, normal, shininess));
	}
	#endif

	#if MAX_SPOT_LIGHTS > 0
	for(int i = 0; i < MAX_SPOT_LIGHTS; ++i) {
		if(i >= lightCount[LIGHT_SPOT]) break;
		SpotLight L = spotLights[i];
		vec2 levels = spotLight(L.position.xyz, L.direction.xyz, L.color.w, L.direction.w, L.position.w, viewPosition, normal, shininess);
		#ifdef SHADOW_GLSL
		float shadow = 1.0;
		if(L.shadowData[ESHADOW_CASTER] >= 0.0 && levels.s != 0.0) shadow = shadowSpot(spotShadowLightSpace[i], L.shadowRegion, L.shadowData[ESHADOW_BIAS], L.shadowData[ESHADOW_BLUR]);
		#else
		const float shadow = 1.0;
		#endif
		addLight(diffuse, specular, L.color.rgb, shadow * levels);
	}
	#endif

	#if MAX_AREA_LIGHTS > 0
	for(int i = 0; i < MAX_AREA_LIGHTS; ++i) {
		if(i >= lightCount[LIGHT_AREA]) break;
		AreaLight L = areaLights[i];
		#ifdef SHADOW_GLSL
		float shadow = 1.0;
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) shadow = shadowArea(areaShadowLightSpace[0]);
		#else
		const float shadow = 1.0;
		#endif
		addLight(diffuse, specular, L.color.rgb, shadow * areaLight(L.position.xyz, L.direction.xyz, L.sdfData, L.color.w, L.position.w, viewPosition, normal, shininess));
	}
	#endif

	unlit *= diffuse;
	return unlit + specular * lightSpecular;
}
#endif