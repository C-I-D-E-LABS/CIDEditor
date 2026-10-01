// Default composite vertex shader, include this if you only need fragment
#include "foxlite/inc/foxlite.glsl" // For texture coordinates
#include "foxlite/inc/mesh.glsl"     // For mesh

void main(void) {
	foxlite_TexCoordv = foxlite_TexCoord;
    gl_Position = vec4(foxlite_Position.x, -foxlite_Position.y, 0.0, 1.0);
}