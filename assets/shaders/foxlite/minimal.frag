#include "foxlite/inc/foxlite.glsl"
#include "foxlite/inc/material.glsl"

void main() {
	#ifndef SOLID
	vec4 albedo = texture2D(bitmap, foxlite_TexCoordv) * foxlite_Colorv;
	#else
	vec4 albedo = foxlite_Colorv;
	#endif
	
	gl_FragData[0] = albedo;
}