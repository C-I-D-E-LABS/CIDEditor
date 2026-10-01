
attribute vec4 foxlite_Position;
attribute vec2 foxlite_TexCoord;
attribute vec3 foxlite_Normal;
attribute vec4 foxlite_Tangent; // Precomputed tangent from normal, used for TBN matrix for advanced light calculations.

#ifdef VERTEX_COLORS
attribute vec4 foxlite_Color;
#else
#define foxlite_Color vec4(1)
#endif

// For instancing
attribute vec4 foxlite_InstanceData0;
attribute vec4 foxlite_InstanceData1;
attribute vec4 foxlite_InstanceData2;
#ifndef DISABLE_INSTANCE_COLOR
attribute vec4 foxlite_InstanceColor;
#else
#define foxlite_InstanceColor vec4(1)
#endif

uniform bool uInstanced;

#define foxlite_InstanceTransform mat4(vec3(foxlite_InstanceData0), 0, vec3(foxlite_InstanceData1), 0, vec3(foxlite_InstanceData2), 0, foxlite_InstanceData0.w, foxlite_InstanceData1.w, foxlite_InstanceData2.w, 1)