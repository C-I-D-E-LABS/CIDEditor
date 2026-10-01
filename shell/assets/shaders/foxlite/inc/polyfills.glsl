// Polyfills...

// Duct-tape fix for: cannot construct 'mat3' from a matrix in GLSL 1.10 (GLSL 1.20 or GLSL ES 1.00 required)
#if __VERSION__ < 120 && !defined(GL_ES)
#define basis(x) mat3(vec3(x[0]), vec3(x[1]), vec3(x[2]))
#else
#define basis mat3
#endif

#if __VERSION__ < 120 || (defined(GL_ES) && __VERSION__ < 300)
mat2 transpose(in mat2 m) {
    vec2 c0 = m[0], c1 = m[1];
	return mat2(
		c0.x, c1.x,
        c0.y, c1.y
	);
}

// From https://shdr.bkcore.com/
mat3 transpose( mat3 m ) {
  vec3 c0 = m[0], c1 = m[1], c2 = m[2];
  return mat3(
    c0.x, c1.x, c2.x,
    c0.y, c1.y, c2.y,
    c0.z, c1.z, c2.z
  );
}

mat4 transpose(in mat4 m) { // Mobile optimized transpose
	vec4 c0 = m[0], c1 = m[1], c2 = m[2], c3 = m[3];
    return mat4(
        c0.x, c1.x, c2.x, c3.x,
        c0.y, c1.y, c2.y, c3.y,
        c0.z, c1.z, c2.z, c3.z,
        c0.w, c1.w, c2.w, c3.w
    );
}
#endif

#if __VERSION__ < 130 
#if !defined(GL_ES)
#define sign(x) (step(0.0, x) * 2.0 - 1.0)
#endif
#endif

#define nearestpo2(x) pow(2.0, floor(log2(x)))

#if __VERSION__ < 130 || (defined(GL_ES) && __VERSION__ < 300)
#define round(x) (floor(x) + step(0.5, fract(x)))
#endif

#if __VERSION__ < 140 || (defined(GL_ES) && __VERSION__ < 300)
// This is a fast fused transpose-inverse function taking mobile compilers into consideration:
// On many GPUs, occupancy drops when a shader uses more than 24-32 VGPRs (AMD, and most likely mobile too) 
// or 32 registers (NVIDIA)
// If the driver can't fit 24+ live scalars, it spills to scratch memory, meaning
// a *10-100x latency penalty per access*
// This code aims to reduce the number of registers used for the calculation:
mat4 fusedInverseTranspose(in mat4 m) {
    float
        a00 = m[0][0], a01 = m[0][1], a02 = m[0][2], a03 = m[0][3],
        a10 = m[1][0], a11 = m[1][1], a12 = m[1][2], a13 = m[1][3],
        a20 = m[2][0], a21 = m[2][1], a22 = m[2][2], a23 = m[2][3],
        a30 = m[3][0], a31 = m[3][1], a32 = m[3][2], a33 = m[3][3],

        // 2x2 sub-determinants from rows 0-1
        b00 = a00*a11 - a01*a10,  b01 = a00*a12 - a02*a10,
        b02 = a00*a13 - a03*a10,  b03 = a01*a12 - a02*a11,
        b04 = a01*a13 - a03*a11,  b05 = a02*a13 - a03*a12, //a00 - a13 are freed, 18 live

        // 2x2 sub-determinants from rows 2-3
        b06 = a20*a31 - a21*a30,  b07 = a20*a32 - a22*a30,
        b08 = a20*a33 - a23*a30,  b09 = a21*a32 - a22*a31,
        b10 = a21*a33 - a23*a31,  b11 = a22*a33 - a23*a32; //a20 - a33 are freed, 20 live

    float det = b00*b11 - b01*b10 + b02*b09 + b03*b08 - b04*b07 + b05*b06;
    float idet = 1.0 / det; // remains one register

    return mat4( // Transposed
        ( a11*b11 - a12*b10 + a13*b09) * idet,
        (-a10*b11 + a12*b08 - a13*b07) * idet,
        ( a10*b10 - a11*b08 + a13*b06) * idet,
        (-a10*b09 + a11*b07 - a12*b06) * idet,

        (-a01*b11 + a02*b10 - a03*b09) * idet,
        ( a00*b11 - a02*b08 + a03*b07) * idet,
        (-a00*b10 + a01*b08 - a03*b06) * idet,
        ( a00*b09 - a01*b07 + a02*b06) * idet,

        ( a31*b05 - a32*b04 + a33*b03) * idet,
        (-a30*b05 + a32*b02 - a33*b01) * idet,
        ( a30*b04 - a31*b02 + a33*b00) * idet,
        (-a30*b03 + a31*b01 - a32*b00) * idet,

        (-a21*b05 + a22*b04 - a23*b03) * idet,
        ( a20*b05 - a22*b02 + a23*b01) * idet,
        (-a20*b04 + a21*b02 - a23*b00) * idet,
        ( a20*b03 - a21*b01 + a22*b00) * idet
    );
}
#else
// Hardware implementations will always be better
#define fusedInverseTranspose(m) transpose(inverse(m))
#endif

