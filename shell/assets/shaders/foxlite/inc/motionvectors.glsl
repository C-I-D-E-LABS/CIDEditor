#ifndef MOTIONVECTORS_GLSL
#define MOTIONVECTORS_GLSL
// Previous transforms to calculate motion vectors
// STILL VERY WIP

// Previous camera position for camera motion
uniform mat4 prevView;

// Motion for simple objects
uniform mat4 prevModel;

// Vertex -> Fragment motion vector data
varying vec4 motionCurClipPos;
varying vec4 motionPrevClipPos;

#ifdef VERTEX
// Motion for animated objects
uniform sampler2D PREV_BONESDATA;

// Motion for instance transforms in instancing mode
attribute vec4 foxlite_PrevInstanceData0;
attribute vec4 foxlite_PrevInstanceData1;
attribute vec4 foxlite_PrevInstanceData2;

#define foxlite_PrevInstanceTransform mat4(vec3(foxlite_PrevInstanceData0), 0, vec3(foxlite_PrevInstanceData1), 0, vec3(foxlite_PrevInstanceData2), 0, foxlite_PrevInstanceData0.w, foxlite_PrevInstanceData1.w, foxlite_PrevInstanceData2.w, 1)

mat4 prevSkin() {
	ivec4 index = ivec4(foxlite_BoneIndex);
	
	mat4 transform =
		fox_textureBufferMat4(PREV_BONESDATA, index.x, BONESDATA_TWIDTH) * foxlite_BoneWeight.x +
		fox_textureBufferMat4(PREV_BONESDATA, index.y, BONESDATA_TWIDTH) * foxlite_BoneWeight.y +
		fox_textureBufferMat4(PREV_BONESDATA, index.z, BONESDATA_TWIDTH) * foxlite_BoneWeight.z +
		fox_textureBufferMat4(PREV_BONESDATA, index.w, BONESDATA_TWIDTH) * foxlite_BoneWeight.w;

	return transform;
}
#endif

vec3 getMotion(vec4 curClipSpace, vec4 prevClipSpace) {
	vec3 curNDC = curClipSpace.xyz / curClipSpace.w;
	vec3 prevNDC = prevClipSpace.xyz / prevClipSpace.w;
	return curNDC - prevNDC;
}
#endif