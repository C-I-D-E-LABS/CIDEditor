#define SKY_PANORAMA_VERT
#include "foxlite/inc/foxlite.glsl" // For texture coordinates
#include "foxlite/inc/mesh.glsl"     // For mesh
#include "foxlite/inc/sky.glsl"      // For worldDirection

void main(void) {
	// We calculate the world direction, this is where the pixel is in the world
	// That position gets affected by camera rotation and projection
	// UV is in screen space, so we have to walk all the way back to world coords
	// check utils.inc for the functions for this
	vec3 ndc = screenToNDC(foxlite_TexCoord);
	vec4 view = ndcToView(ndc);
	
	worldDirection = viewToWorld(view);

    gl_Position = vec4(foxlite_Position.x, -foxlite_Position.y, -1.0, 1.0);
}