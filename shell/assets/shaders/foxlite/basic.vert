
#define BASIC_LIGHTING_VERT
#include "foxlite/inc/foxlite.glsl"
#include "foxlite/inc/mesh.glsl"
#include "foxlite/inc/material.glsl"
#include "foxlite/inc/lighting.glsl"
#include "foxlite/inc/sky.glsl"      // For worldDirection and sky reflections
#include "foxlite/inc/armature.glsl"

#ifdef FORWARDPLUS_MOTION
#include "foxlite/inc/motionvectors.glsl"
#endif

#define transformInstance(M, T) (M = M * T)
#define transformSkinned(M, S) (M = M * S)

#if defined(BILLBOARD)
mat4 transformBillboard(inout mat4 M, in mat4 viewMatrix) {
	mat4 fmodelView = viewMatrix * M;
	#ifdef BILLBOARD_KEEP_SCALE
	vec3 scale = vec3(
		length(vec3(M[0])),
		length(vec3(M[1])),
		length(vec3(m[2]))
	);
	#else
	const vec3 scale = vec3(1);
	#endif
	fmodelView[0] = vec4(scale.x, 0.0, 0.0, 0.0); // right
    fmodelView[1] = vec4(0.0, scale.y, 0.0, 0.0); // up
    fmodelView[2] = vec4(0.0, 0.0, scale.z, 0.0); // forward
	return fmodelView;
}
#elif defined(BILLBOARD_Y)
mat4 transformBillboard(inout mat4 M, in mat4 viewMatrix) {
	vec3 right    = normalize(vec3(viewMatrix[0][0], viewMatrix[1][0], viewMatrix[2][0]));
    const vec3 up = vec3(0.0, 1.0, 0.0);  // locked to world Y
    vec3 forward  = normalize(cross(right, up));
	right = normalize(cross(up, forward)); // reorthogonalize
	
	#ifdef BILLBOARD_KEEP_SCALE
	vec3 scale = vec3(
		length(vec3(M[0])),
		length(vec3(M[1])),
		length(vec3(M[2]))
	);
	#else
	const vec3 scale = vec3(1);
	#endif
	mat4 fmodelView = viewMatrix * mat4(
		vec4(right   * scale.x, 0.0),
		vec4(up      * scale.y, 0.0),
		vec4(forward * scale.z, 0.0),
		M[3]
	);
	return fmodelView;
}
#endif

void main(void)
{
	foxlite_TexCoordv = foxlite_TexCoord * uvScale + uvOffset;
	foxlite_Colorv = foxlite_Color * color;
	
	mat4 worldTransform = model;

	if(uInstanced) {
		foxlite_Colorv *= foxlite_InstanceColor;
		transformInstance(worldTransform, foxlite_InstanceTransform);
	}

	if(uSkinned) transformSkinned(worldTransform, skin());

	#if defined(BILLBOARD) || defined(BILLBOARD_Y)
	mat4 fmodelView = transformBillboard(worldTransform, view);
	#else
	mat4 fmodelView = view * worldTransform;
	#endif

	// Inverting then transposing a mat4 is never good in the GPU
	// but it would take tons and tons of operations in HScript and we don't want that either
	mat4 invfmodelView = fusedInverseTranspose(fmodelView);
	
	vec4 localPosition = vec4(foxlite_Position.xyz, 1.0);
	vec4 worldPosition = worldTransform * localPosition;
	viewPosition = fmodelView * localPosition;

	modelViewNormal = normalize(basis(invfmodelView) * foxlite_Normal);

	#ifdef NORMAL_MAP
	vec3 tangentView = normalize(basis(invfmodelView) * foxlite_Tangent.xyz);
	
	// Re-orthogonalize tangent with respect to normal (Gram-Schmidt)
	// This is done because the tangent might not be perfectly perpendicular to Normal
	tangentView = normalize(tangentView - dot(tangentView, modelViewNormal) * modelViewNormal);

	// Create TBN matrix
	TBN = tbnNormalTangent(modelViewNormal, tangentView);
	TBN[1] *= foxlite_Tangent.w; // bitangent handedness
	#endif

	#ifdef SKY_REFLECTIONS
	worldDirection = viewToWorld(viewPosition);
	worldBasis = transpose(basis(invView));
	#endif

	#ifdef VERTEX_LIGHTING
	// Doesn't make much sense to calculate PBR materials here

	#ifdef FOG
	
	#ifdef FAST_FOG
	float fogStrength = -viewPosition.z;
	#else
	float fogStrength = length(viewPosition);
	#endif

	// Vertex interpolated fog
	fogStrength = clamp((fogStrength - fogStart) / (fogEnd - fogStart), 0.0, 1.0);
	#else
	const float fogStrength = 0.0;
	#endif

	float shininess = (1.0 - uRoughness) * (1.0 - uRoughness) * 256.0;
	foxlite_Colorv.rgb = light(foxlite_Colorv.rgb, -modelViewNormal, viewPosition.xyz, uSpecular, shininess);

	#ifdef FOG 
	
	#ifdef LINEAR_FOG
	foxlite_Colorv.rgb = mix(foxlite_Colorv.rgb, fogColor, fogStrength);
	#else
	foxlite_Colorv.rgb = mix(foxlite_Colorv.rgb, fogColor, fogStrength * fogStrength);
	#endif
	#endif
	
	#elif !defined(UNSHADED) && defined(SHADOW_GLSL) && !defined(SHADOW_PASS)
	setupShadows(worldPosition);
	#endif

	gl_Position = projection * viewPosition;

	/////////////////////////////// Motion vectors ///////////////////////////////

	#if defined(FORWARDPLUS_MOTION) && defined(MOTIONVECTORS_GLSL)

	mat4 prevWorldTransform = prevModel;

	if(uInstanced) transformInstance(prevWorldTransform, foxlite_PrevInstanceTransform);

	if(uSkinned) transformSkinned(prevWorldTransform, prevSkin());

	#if defined(BILLBOARD) || defined(BILLBOARD_Y)
	mat4 prevFmodelView = transformBillboard(prevWorldTransform, prevView);
	#else
	mat4 prevFmodelView = prevView * prevWorldTransform;
	#endif

	vec4 prevViewPos = prevFmodelView * localPosition;
	vec4 prevClipPos = projection * prevViewPos;

	motionCurClipPos = gl_Position;
	motionPrevClipPos = prevClipPos;
	#endif
}