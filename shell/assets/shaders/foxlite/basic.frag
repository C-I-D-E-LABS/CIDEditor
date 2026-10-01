
#define BASIC_LIGHTING_FRAG
#include "foxlite/inc/foxlite.glsl"
#include "foxlite/inc/material.glsl"
#include "foxlite/inc/lighting.glsl"
#include "foxlite/inc/sky.glsl"      // For worldDirection and sky funcs

#ifdef FORWARDPLUS_MOTION
#include "foxlite/inc/motionvectors.glsl"
#endif

void main() {
	#ifndef SOLID
	
	#ifdef SCREEN_UV_AS_COORD
	vec4 albedo = texture2D(bitmap, ScreenUV);
	#else
	vec4 albedo = texture2D(bitmap, foxlite_TexCoordv);
	#endif
	albedo *= foxlite_Colorv;
	
	#if !defined(NO_ALPHA_SCISSOR) && !(defined(ALPHA_DITHER) || defined(ALPHA_DITHER_FAST))
	if(albedo.a < alphaScissor) discard; // Alpha cutout (disabled when alpha dithering is enabled)
	#endif
	#else
	vec4 albedo = foxlite_Colorv;
	#endif

	#if defined(ALPHA_DITHER) || defined(ALPHA_DITHER_FAST)
	if(alphaDither(albedo.a) < 1.0) discard;
	albedo.a = 1.0;
	#endif

	#ifdef SHADOW_PASS
	// Stop code here, we don't need any extra operations
	gl_FragData[0] = albedo;
	return;
	#endif

	vec3 normalView = modelViewNormal;

	#ifndef VERTEX_LIGHTING

	#ifdef FOG

	#ifdef FAST_FOG
	float fogStrength = -viewPosition.z;
	#else
	float fogStrength = length(viewPosition);
	#endif

	fogStrength = clamp((fogStrength - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
	#else
	const float fogStrength = 0.0;
	#endif

	//if(fogStrength < 1.0) { // Fog occlusion, prevents expensive calculations on fully fog-occluded pixels.
	#ifdef NORMAL_MAP
		vec3 tangentNormal = texture2D(normalMap, foxlite_TexCoordv).xyz * 2.0 - 1.0;
		normalView = normalize(TBN * tangentNormal);
	#endif
		
	#ifdef ORM_MAP
		vec3 specular   = uSpecular;
		float roughness = uRoughness;
		float metallic  = uMetallic;

		// From the glTF 2.0 spec
		vec4 ormData = texture2D(ormMap, foxlite_TexCoordv);
		float ao   = ormData.r;
		roughness += ormData.g;
		metallic  += ormData.b;
	#else
		// const uniform hack for GLES
		#define specular uSpecular
		#define roughness uRoughness
		#define metallic uMetallic
		const float ao = 1.0;
	#endif

	#ifndef UNSHADED
	float shininess = max((1.0 - roughness) * (1.0 - roughness) * 256.0, 1.0);
	albedo.rgb = light(albedo.rgb * ao, -normalView, viewPosition.xyz, specular, shininess);
	#endif

	#ifdef SKY_REFLECTIONS
		vec3 dir = reflect(normalize(worldDirection), worldBasis * normalView);
		//float costheta = -dot(normalize(viewPosition.xyz), normalView);
		//float fresnel = fresnelSchlick(clamp(costheta, 0.0, 1.0), 0.05);
		vec4 skyColor = panoramaSky(skyTexture, dir, pow(8.0, roughness)-1.0);
	#ifdef SKY_RADIANCE
		vec4 envColor = pow(panoramaSky(skyTexture, dir, float(SKY_RADIANCE_LEVEL)), 1./vec4(4));	
		albedo *= envColor;
	#endif
		albedo = mix(albedo, skyColor, clamp(metallic, 0.0, 1.0));
	#else
		albedo.rgb *= 1.0 - metallic;
	#endif
	
	//}
	#ifdef FOG
	
	#ifndef FOG_TRANSPARENCY
		// const uniform hack for GLES
		#define fogFragColor fogColor.rgb
	#else
		vec3 fogFragColor = mix(gl_LastFragData[0].rgb, fogColor.rgb, fogColor.a);
	#endif
	
	#ifdef LINEAR_FOG
		albedo.rgb = mix(albedo.rgb, fogFragColor, fogStrength);
	#else
		albedo.rgb = mix(albedo.rgb, fogFragColor, fogStrength * fogStrength);
	#endif

	#endif
	#endif

	#ifdef EMISSIVE_MAP
	vec3 emission = uEmissive * texture2D(emissiveMap, foxlite_TexCoordv).rgb;
	albedo.rgb += emission;
	#else
	#define emission uEmissive;
	albedo.rgb += uEmissive;
	#endif

	gl_FragData[0] = albedo;
	
	#ifdef FORWARDPLUS
	gl_FragData[1].xyz = normalView;
	gl_FragData[1].w = metallic;
	#endif
	#if defined(FORWARDPLUS_MOTION) && defined(MOTIONVECTORS_GLSL)
	gl_FragData[2].xyz = getMotion(motionCurClipPos, motionPrevClipPos);
	gl_FragData[2].w = roughness;
	#endif
}