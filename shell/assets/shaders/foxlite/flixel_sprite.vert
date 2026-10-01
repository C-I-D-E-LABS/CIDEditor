#pragma header

uniform vec4 flixel_Screen;

// No matrix support. thanks flixel.
uniform vec4 foxlite_MVP_row0;
uniform vec4 foxlite_MVP_row1;
uniform vec4 foxlite_MVP_row2;
uniform vec4 foxlite_MVP_row3;

#define foxlite_MVP mat4( \
	foxlite_MVP_row0,	  \
	foxlite_MVP_row1,	  \
	foxlite_MVP_row2,	  \
	foxlite_MVP_row3)

void main(void) {
	#pragma body

	vec2 position = (openfl_Position.xy - flixel_Screen.xy) * flixel_Screen.zw;
	position.x *= -flixel_Screen.w / flixel_Screen.z; // aspect correction
	gl_Position = foxlite_MVP * vec4(position.xy, 0, 1);
}