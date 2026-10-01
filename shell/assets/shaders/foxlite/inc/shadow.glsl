#ifndef SHADOW_GLSL
#define SHADOW_GLSL

#ifdef VERTEX
uniform sampler2D shadowCasterData;
uniform float shadowCasterDataSize;
#endif

uniform sampler2D shadowtex0; // Directional light shadow atlas
uniform samplerCube shadowtex1; // wip - Point light shadow cubemap
uniform sampler2D shadowtex2; // Spot light shadow atlas
uniform samplerCube shadowtex3; // wip - Area light shadow cubemap

uniform vec2 shadowtex0size;
uniform vec2 shadowtex2size;

#if MAX_DIRECTIONAL_LIGHTS > 0
	varying vec4 directionalShadowLightSpace[MAX_DIRECTIONAL_LIGHTS];
#endif
#if MAX_POINT_LIGHTS > 0
	varying vec4 pointShadowLightSpace[1];
#endif
#if MAX_SPOT_LIGHTS > 0
	varying vec4 spotShadowLightSpace[MAX_SPOT_LIGHTS];
#endif
#if MAX_AREA_LIGHTS > 0
	varying vec4 areaShadowLightSpace[1];
#endif

// Shadow data
#define ESHADOW_CASTER 0
#define ESHADOW_BIAS 1
#define ESHADOW_BLUR 2
#define ESHADOW_NORMAL_BIAS 3

// For shadow clipping
#define outsideBounds(v) any(bvec2(any(lessThan(v, vec2(0))), any(greaterThan(v, vec2(1)))))

#ifdef VERTEX
void setupShadows(vec4 worldPosition) {

	#if MAX_DIRECTIONAL_LIGHTS > 0
	for(int i = 0; i < MAX_DIRECTIONAL_LIGHTS; ++i) {
		if(i >= lightCount[LIGHT_DIRECTIONAL]) break;
		DirLight L = directionalLights[i];
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) {
			mat4 viewProjection = fox_textureBufferMat4(shadowCasterData, int(L.shadowData[ESHADOW_CASTER]), shadowCasterDataSize);
			directionalShadowLightSpace[i] = viewProjection * worldPosition;
			directionalShadowLightSpace[i].xyz = directionalShadowLightSpace[i].xyz * 0.5 + 0.5;
			directionalShadowLightSpace[i].z -= L.shadowData[ESHADOW_BIAS];
		}
	}
	#endif

	#if MAX_POINT_LIGHTS > 0
	for(int i = 0; i < 1; ++i) {
		if(i >= lightCount[LIGHT_POINT]) break;
		PointLight L = pointLights[i];
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) {
			mat4 viewProjection = fox_textureBufferMat4(shadowCasterData, int(L.shadowData[ESHADOW_CASTER]), shadowCasterDataSize);
			pointShadowLightSpace[i] = viewProjection * worldPosition;
		}
	}
	#endif

	#if MAX_SPOT_LIGHTS > 0
	for(int i = 0; i < MAX_SPOT_LIGHTS; ++i) {
		if(i >= lightCount[LIGHT_SPOT]) break;
		SpotLight L = spotLights[i];
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) {
			mat4 viewProjection = fox_textureBufferMat4(shadowCasterData, int(L.shadowData[ESHADOW_CASTER]), shadowCasterDataSize);
			spotShadowLightSpace[i] = viewProjection * worldPosition;
		}
	}
	#endif

	#if MAX_AREA_LIGHTS > 0
	for(int i = 0; i < 1; ++i) {
		if(i >= lightCount[LIGHT_AREA]) break;
		AreaLight L = areaLights[i];
		if(L.shadowData[ESHADOW_CASTER] >= 0.0) {
			mat4 viewProjection = fox_textureBufferMat4(shadowCasterData, int(L.shadowData[ESHADOW_CASTER]), shadowCasterDataSize);
			areaShadowLightSpace[i] = viewProjection * worldPosition;
		}
	}
	#endif

}
#endif

float sampleShadow(sampler2D tex, vec2 coord, float Z) {
	return step(texture2D(tex, coord).r, Z);
}

// For any custom implementations, use along SHADOW_FILTER_CUSTOM
float sampleShadowCustom(sampler2D tex, vec2 coord, float Z, vec2 S);

// Based on https://www.shadertoy.com/view/lsfGWn
float sampleShadowPoisson5(sampler2D tex, vec2 coord, float Z, vec2 S) {
	float pDepth = 0.0;
	float a = interleavedGradientNoise(ScreenCoord) * 6.28;
	vec2 sc = vec2(sin(a),cos(a));
	vec4 B = vec4(sc.y, sc.x, -sc.x, sc.y);

	// Unrolled for OpenGL ES 2
	const float NUM_TAPS = 5.0;
	vec2 ofs, texcoord;
	ofs = vec2(-0.8350818852979401, -0.4826388224290488); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(0.24593728246082208, 0.9588613067368342); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(0.7796384216727746, -0.6037360528260651); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(-0.6437966602266678, 0.692457694761556); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(0.45504401297974184, -0.3128321923487644); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	return pDepth / NUM_TAPS;
}

float sampleShadowPoisson18(sampler2D tex, vec2 coord, float Z, vec2 S) {
	float pDepth = 0.0;
	float a = interleavedGradientNoise(ScreenCoord) * 6.28;
	vec2 sc = vec2(sin(a),cos(a));
	vec4 B = vec4(sc.y, sc.x, -sc.x, sc.y);

	// Unrolled for OpenGL ES 2
	const float NUM_TAPS = 18.0;
	vec2 ofs, texcoord;
	ofs = vec2(-0.220147, 0.976896); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(-0.735514, 0.693436); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(-0.200476, 0.310353); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.180822, 0.454146); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.292754, 0.937414); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.564255, 0.207879); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.178031, 0.024583); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.613912,-0.205936); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(-0.385540,-0.070092); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.962838, 0.378319); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(-0.886362, 0.032122); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(-0.466531,-0.741458); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.006773,-0.574796); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(-0.739828,-0.410584); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.590785,-0.697557); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2(-0.081436,-0.963262); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 1.000000,-0.100160); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);
	ofs = vec2( 0.622430, 0.680868); ofs = vec2( dot(ofs,B.xy), dot(ofs,B.zw) ) * S; texcoord = coord + ofs;
	pDepth += sampleShadow(tex, texcoord, Z);

	return pDepth / NUM_TAPS;
}

float shadowDirectional(in vec4 projCoords, const vec4 rect, in float blur) {
	//vec3 projCoords = S.xyz;
	float shadow = 1.0;
	#if MAX_DIRECTIONAL_LIGHTS > 0
	if(!outsideBounds(projCoords.xy)) {
		vec2 coord = mix(rect.xy, rect.zw, projCoords.xy); // Atlas rect
		
		#ifdef SHADOW_FILTER_NONE
		shadow -= sampleShadow(shadowtex0, coord, projCoords.z);
		#elif defined(SHADOW_FILTER_CUSTOM)
		shadow -= sampleShadowCustom(shadowtex0, coord, projCoords.z, shadowtex0size*blur);
		#elif defined(SHADOW_FILTER_LQ)
		shadow -= sampleShadowPoisson5(shadowtex0, coord, projCoords.z, shadowtex0size*blur);
		#else
		shadow -= sampleShadowPoisson18(shadowtex0, coord, projCoords.z, shadowtex0size*blur);
		#endif
	}
	#endif
	return shadow;
}

float shadowSpot(in vec4 S, const vec4 rect, in float bias, in float blur) {
	vec3 projCoords = S.xyz / S.w;
	projCoords = projCoords * 0.5 + 0.5;
	projCoords.z -= bias;

	float shadow = 1.0;
	#if MAX_SPOT_LIGHTS > 0
	if(!outsideBounds(projCoords.xy)) {
		vec2 coord = mix(rect.xy, rect.zw, projCoords.xy); // Atlas rect
		
		#ifdef SHADOW_FILTER_NONE
		shadow -= sampleShadow(shadowtex2, coord, projCoords.z);
		#elif defined(SHADOW_FILTER_CUSTOM)
		shadow -= sampleShadowCustom(shadowtex2, coord, projCoords.z, shadowtex2size*blur);
		#elif defined(SHADOW_FILTER_LQ)
		shadow -= sampleShadowPoisson5(shadowtex2, coord, projCoords.z, shadowtex2size*blur);
		#else
		shadow -= sampleShadowPoisson18(shadowtex2, coord, projCoords.z, shadowtex2size*blur);
		#endif
	}
	#endif
	return shadow;
}

float shadowPointCubemap(in vec4 S) {
	return 1.0;
}

float shadowArea(in vec4 S) {
	return 1.0;
}
#endif
