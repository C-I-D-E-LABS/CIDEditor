// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float intensity;

// variables which are empty, they need just to avoid crashing shader
uniform vec4 iMouse;

// end of ShadertoyToFlixel header

// Created by Darko (omegasbk) 
// youtube.com/c/darkosupe

struct Camera
{
    vec3 position;
    float focalDistance;
};    

struct Plane 
{
    vec3 position;
    vec3 normal;
    vec3 color;
};
struct PointLight
{
    vec3 position;
    float intensity;
};

Plane plane = Plane(
    vec3(0., 0., 1.), 
    vec3(0., 0., -1.), 
    vec3(0.5, 0.5, 0.5));
    
PointLight light = PointLight(
    vec3(0., 0.19, -0.2), // position
    35.);                 // intensity
    
Camera camera = Camera(
    vec3(0., 0., -0.3), 
    0.6);
    
//////////////////////////////////////////////////////////////
// 	                        UTILS                           // 
//////////////////////////////////////////////////////////////
bool solveQuadratic(float a, float b, float c, out float t0, out float t1)
{
    float disc = b * b - 4. * a * c;
    
    if (disc < 0.)
    {
        return false;
    } 
    
    if (disc == 0.)
    {
        t0 = t1 = -b / (2. * a);
        return true;
    }
    
    t0 = (-b + sqrt(disc)) / (2. * a);
    t1 = (-b - sqrt(disc)) / (2. * a);
    return true;    
}


//////////////////////////////////////////////////////////////
// Taken from https://www.shadertoy.com/view/XsX3zB
/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
vec3 random3(vec3 c) 
{
	float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
	vec3 r;
	r.z = fract(512.0*j);
	j *= .125;
	r.x = fract(512.0*j);
	j *= .125;
	r.y = fract(512.0*j);
	return r-0.5;
}

/* skew constants for 3d simplex functions */
const float F3 =  0.3333333;
const float G3 =  0.1666667;

/* 3d simplex noise */
float simplex3d(vec3 p) 
{
	 /* 1. find current tetrahedron T and it's four vertices */
	 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/
	 
	 /* calculate s and x */
	 vec3 s = floor(p + dot(p, vec3(F3)));
	 vec3 x = p - s + dot(s, vec3(G3));
	 
	 /* calculate i1 and i2 */
	 vec3 e = step(vec3(0.0), x - x.yzx);
	 vec3 i1 = e*(1.0 - e.zxy);
	 vec3 i2 = 1.0 - e.zxy*(1.0 - e);
	 	
	 /* x1, x2, x3 */
	 vec3 x1 = x - i1 + G3;
	 vec3 x2 = x - i2 + 2.0*G3;
	 vec3 x3 = x - 1.0 + 3.0*G3;
	 
	 /* 2. find four surflets and store them in d */
	 vec4 w, d;
	 
	 /* calculate surflet weights */
	 w.x = dot(x, x);
	 w.y = dot(x1, x1);
	 w.z = dot(x2, x2);
	 w.w = dot(x3, x3);
	 
	 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	 w = max(0.6 - w, 0.0);
	 
	 /* calculate surflet components */
	 d.x = dot(random3(s), x);
	 d.y = dot(random3(s + i1), x1);
	 d.z = dot(random3(s + i2), x2);
	 d.w = dot(random3(s + 1.0), x3);
	 
	 /* multiply d by w^4 */
	 w *= w;
	 w *= w;
	 d *= w;
	 
	 /* 3. return the sum of the four surflets */
	 return dot(d, vec4(52.0));
}

/* const matrices for 3d rotation */
const mat3 rot1 = mat3(-0.37, 0.36, 0.85,-0.14,-0.93, 0.34,0.92, 0.01,0.4);
const mat3 rot2 = mat3(-0.55,-0.39, 0.74, 0.33,-0.91,-0.24,0.77, 0.12,0.63);
const mat3 rot3 = mat3(-0.71, 0.52,-0.47,-0.08,-0.72,-0.68,-0.7,-0.45,0.56);

/* directional artifacts can be reduced by rotating each octave */
float simplex3d_fractal(vec3 m) 
{
    return   0.5333333*simplex3d(m*rot1)
			+0.2666667*simplex3d(2.0*m*rot2)
			+0.1333333*simplex3d(4.0*m*rot3)
			+0.0666667*simplex3d(8.0*m);
}
//
//////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
// 	                   INTERSECTION CODE                    // 
//////////////////////////////////////////////////////////////
bool intersectPlane(in Plane plane, in vec3 origin, in vec3 rayDirection, out float t, out vec3 pHit) 
{    
    // Assuming vectors are all normalized
    float denom = dot(plane.normal, rayDirection); 
    if (denom < 1e-6) 
    { 
        vec3 p0l0 = plane.position - origin; 
        t = dot(p0l0, plane.normal) / denom; 
        
        if (t >= 0.)
        {
            pHit = origin + rayDirection * t;
            return true;
        }             
    } 
 
    return false; 
} 

//////////////////////////////////////////////////////////////
// 	                       MAIN CODE                        // 
//////////////////////////////////////////////////////////////
float rayTrace(in vec3 rayDirection, in vec3 rayOrigin)
{
    float objectHitDistance;
    vec3 pHit;

#define LAYERS 3
#define SHADOW_LAYERS 3
#define FOG_DENSITY 0.1

    float accAlpha = 0.;
    
    Plane diffusePlane = plane;
    Plane lightPlane = plane;
    vec3 lightDirection;
    
    for (int i = 0; i < LAYERS; i++)
    {
        if (intersectPlane(diffusePlane, rayOrigin, rayDirection, objectHitDistance, pHit))
        {
            float thickness = simplex3d_fractal(pHit);
            accAlpha += thickness * FOG_DENSITY;            

            //lightDirection = normalize(light.position - pHit);

            vec3 shadowPhit = pHit;
            for (int j = 0; j < i; j++)
            {
                shadowPhit += FOG_DENSITY * lightDirection;
                accAlpha -= simplex3d_fractal(shadowPhit) * 0.008;
            }
        }
        
        diffusePlane.position.z += FOG_DENSITY;
    }        
 
    return accAlpha;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float time = iTime / 4.;
    light.position.x = iMouse.x / iResolution.x;
    //light.position.z = time - 1.2;
    
    plane.position.z = time;
    camera.position.z = time - 1.2;
        
    // Normalized pixel coordinates (from -0.5 to 0.5)
    vec2 uv = fragCoord/iResolution.xy - 0.5;
    uv.x *= (iResolution.x / iResolution.y); 
    
    vec3 clipPlanePosition = vec3(uv.x, uv.y, camera.position.z + camera.focalDistance);
    vec3 rayDirection = normalize(clipPlanePosition - camera.position);
    
    vec4 ambientColor = vec4(0.5, 0.7, 0.9, 1.) * (-uv.y + 0.1);  
    vec4 finalColor = ambientColor + rayTrace(rayDirection, camera.position);
    
    finalColor.rgb *= intensity;
    finalColor.a = intensity;

    fragColor = finalColor;
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}