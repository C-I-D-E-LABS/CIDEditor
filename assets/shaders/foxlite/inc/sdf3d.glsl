// 3D SDF Functions by Inigo Quilez:
// https://iquilezles.org/articles/distfunctions/

#define SDF_SPHERE 0
#define SDF_BOX 1
#define SDF_TORUS 2
#define SDF_CAPPED_TORUS 3
#define SDF_LINK 4
#define SDF_HEX_PRISM 5

/*
	r: radius
*/
float sdSphere3D( vec3 p, float r )
{
  return length(p) - r;
}

/*
	b.x: size X
	b.y: size Y
	b.z: size Z
*/
float sdBox3D( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

/*
	t.x: radius
	t.y: thickness
*/
float sdTorus3D( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

// Modified so it accepts angle rather than components, to fit in a vec3
/*
	sc: angle cap component, as `vec2(sin(a),cos(a))` (starts at bottom)
	ra: radius
	rb: thickness
*/
float sdCappedTorus3D(in vec3 p, in vec2 sc, in float ra, in float rb)
{
    p.x = abs(p.x);
    float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
    return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

/*
	le: length
	r1: "radius"
	r2: thickness
*/
float sdLink3D( vec3 p, float le, float r1, float r2 )
{
  vec3 q = vec3( p.x, max(abs(p.y)-le,0.0), p.z );
  return length(vec2(length(q.xy)-r1,q.z)) - r2;
}

/*
	h.x: thickness
	h.y: length
*/
float sdHexPrism3D( vec3 p, vec2 h )
{
  const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
  p = abs(p);
  p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
  vec2 d = vec2(
       length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
       p.z-h.y );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float getSDF3D(int func, vec3 p, vec3 data) {
	float sdf = 0.0;
	if(func == SDF_BOX) sdf = sdBox3D(p, data);
	else if(func == SDF_TORUS) sdf = sdTorus3D(p, data.xy);
	else if(func == SDF_CAPPED_TORUS) sdf = sdCappedTorus3D(p, vec2(cos(data.z), sin(data.z)), data.x, data.y);
	else if(func == SDF_LINK) sdf = sdLink3D(p, data.z, data.x, data.y);
	else if(func == SDF_HEX_PRISM) sdf = sdHexPrism3D(p, data.xy);
	else sdf = sdSphere3D(p, data.x);
	return sdf;
}