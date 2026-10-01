#include "foxlite/inc/foxlite.glsl"
#include "foxlite/inc/material.glsl" // for color
#include "foxlite/inc/mesh.glsl"
#include "foxlite/inc/armature.glsl"

void main(void)
{
	foxlite_TexCoordv = foxlite_TexCoord * uvScale + uvOffset;
	foxlite_Colorv = foxlite_Color * color;

	mat4 worldTransform = model;

	// Instancing
	if(uInstanced) {
		foxlite_Colorv *= foxlite_InstanceColor;
		worldTransform = worldTransform * foxlite_InstanceTransform;
	}

	mat4 fmodelView = view * worldTransform;
	
	// Skinning
	if(uSkinned) fmodelView = fmodelView * skin();

	gl_Position = projection * fmodelView * vec4(foxlite_Position.xyz, 1.0);
}